/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXBitMatrix.h"
#import "ZXBinaryBitmap.h"
#import "ZXDecodeHints.h"
#import "ZXDetectorResult.h"
#import "ZXErrors.h"
#import "ZXGridSampler.h"
#import "ZXLinesSampler.h"
#import "ZXMathUtils.h"
#import "ZXPDF417Detector.h"
#import "ZXPerspectiveTransform.h"
#import "ZXResultPoint.h"

int const PDF417_INTEGER_MATH_SHIFT = 8;
int const PDF417_PATTERN_MATCH_RESULT_SCALE_FACTOR = 1 << PDF417_INTEGER_MATH_SHIFT;
int const MAX_AVG_VARIANCE = (int) (PDF417_PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.42f);
int const MAX_INDIVIDUAL_VARIANCE = (int) (PDF417_PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.8f);

// B S B S B S B S Bar/Space pattern
// 11111111 0 1 0 1 0 1 000
int const PDF417_START_PATTERN_LEN = 8;
int const PDF417_START_PATTERN[PDF417_START_PATTERN_LEN] = {8, 1, 1, 1, 1, 1, 1, 3};

// 11111111 0 1 0 1 0 1 000
int const START_PATTERN_REVERSE_LEN = 8;
int const START_PATTERN_REVERSE[START_PATTERN_REVERSE_LEN] = {3, 1, 1, 1, 1, 1, 1, 8};

// 1111111 0 1 000 1 0 1 00 1
int const STOP_PATTERN_LEN = 9;
int const STOP_PATTERN[STOP_PATTERN_LEN] = {7, 1, 1, 3, 1, 1, 1, 2, 1};

// B S B S B S B S B Bar/Space pattern
// 1111111 0 1 000 1 0 1 00 1
int const STOP_PATTERN_REVERSE_LEN = 9;
int const STOP_PATTERN_REVERSE[STOP_PATTERN_REVERSE_LEN] = {1, 2, 1, 1, 1, 3, 1, 1, 7};

@interface ZXPDF417Detector ()

@property (nonatomic, strong) ZXBinaryBitmap *image;

@end

@implementation ZXPDF417Detector

- (id)initWithImage:(ZXBinaryBitmap *)image {
  if (self = [super init]) {
    _image = image;
  }

  return self;
}

/**
 * Detects a PDF417 Code in an image, simply.
 */
- (ZXDetectorResult *)detectWithError:(NSError **)error {
  return [self detect:nil error:error];
}

/**
 * Detects a PDF417 Code in an image. Only checks 0 and 180 degree rotations.
 */
- (ZXDetectorResult *)detect:(ZXDecodeHints *)hints error:(NSError **)error {
  // Fetch the 1 bit matrix once up front.
  ZXBitMatrix *matrix = [self.image blackMatrixWithError:error];
  if (!matrix) {
    return nil;
  }

  // Try to find the vertices assuming the image is upright.
  int rowStep = 8;
  NSMutableArray *vertices = [self findVertices:matrix rowStep:rowStep];
  if (vertices == nil) {
    // Maybe the image is rotated 180 degrees?
    vertices = [self findVertices180:matrix rowStep:rowStep];
    if (vertices != nil) {
      if (![self correctVertices:matrix vertices:vertices upsideDown:YES]) {
        if (error) *error = NotFoundErrorInstance();
        return nil;
      }
    }
  } else {
    if (![self correctVertices:matrix vertices:vertices upsideDown:NO]) {
      if (error) *error = NotFoundErrorInstance();
      return nil;
    }
  }

  if (vertices == nil) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  float moduleWidth = [self computeModuleWidth:vertices];
  if (moduleWidth < 1.0f) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  int dimension = [self computeDimension:vertices[12]
                                topRight:vertices[14]
                              bottomLeft:vertices[13]
                             bottomRight:vertices[15]
                             moduleWidth:moduleWidth];
  if (dimension < 1) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  int yDimension = MAX([self computeYDimension:vertices[12]
                                      topRight:vertices[14]
                                    bottomLeft:vertices[13]
                                   bottomRight:vertices[15]
                                   moduleWidth:moduleWidth],
                       dimension);

  // Deskew and over-sample image.
  ZXBitMatrix *linesMatrix = [self sampleLines:vertices dimension:dimension yDimension:yDimension];
  if (!linesMatrix) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  ZXBitMatrix *linesGrid = [[[ZXLinesSampler alloc] initWithLinesMatrix:linesMatrix dimension:dimension] sample];

  //TODO: verify vertex indices.
  return [[ZXDetectorResult alloc] initWithBits:linesGrid
                                         points:@[vertices[5], vertices[4], vertices[6], vertices[7]]];
}

/**
 * Locate the vertices and the codewords area of a black blob using the Start
 * and Stop patterns as locators.
 * 
 * Returns an array containing the vertices:
 * vertices[0] x, y top left barcode
 * vertices[1] x, y bottom left barcode
 * vertices[2] x, y top right barcode
 * vertices[3] x, y bottom right barcode
 * vertices[4] x, y top left codeword area
 * vertices[5] x, y bottom left codeword area
 * vertices[6] x, y top right codeword area
 * vertices[7] x, y bottom right codeword area
 */
- (NSMutableArray *)findVertices:(ZXBitMatrix *)matrix rowStep:(int)rowStep {
  int height = matrix.height;
  int width = matrix.width;

  NSMutableArray *result = [NSMutableArray arrayWithCapacity:16];
  for (int i = 0; i < 8; i++) {
    [result addObject:[NSNull null]];
  }
  BOOL found = NO;

  int counters[START_PATTERN_REVERSE_LEN];
  memset(counters, 0, START_PATTERN_REVERSE_LEN * sizeof(int));

  // Top Left
  for (int i = 0; i < height; i += rowStep) {
    NSRange loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:(int *)PDF417_START_PATTERN patternLen:PDF417_START_PATTERN_LEN counters:counters];
    if (loc.location != NSNotFound) {
      result[0] = [[ZXResultPoint alloc] initWithX:loc.location y:i];
      result[4] = [[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i];
      found = YES;
      break;
    }
  }
  // Bottom left
  if (found) { // Found the Top Left vertex
    found = NO;
    for (int i = height - 1; i > 0; i -= rowStep) {
      NSRange loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:(int *)PDF417_START_PATTERN patternLen:PDF417_START_PATTERN_LEN counters:counters];
      if (loc.location != NSNotFound) {
        result[1] = [[ZXResultPoint alloc] initWithX:loc.location y:i];
        result[5] = [[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i];
        found = YES;
        break;
      }
    }
  }

  int counters2[STOP_PATTERN_REVERSE_LEN];
  memset(counters2, 0, STOP_PATTERN_REVERSE_LEN * sizeof(int));

  // Top right
  if (found) { // Found the Bottom Left vertex
    found = NO;
    for (int i = 0; i < height; i += rowStep) {
      NSRange loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:(int *)STOP_PATTERN patternLen:STOP_PATTERN_LEN counters:counters2];
      if (loc.location != NSNotFound) {
        result[2] = [[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i];
        result[6] = [[ZXResultPoint alloc] initWithX:loc.location y:i];
        found = YES;
        break;
      }
    }
  }
  // Bottom right
  if (found) { // Found the Top right vertex
    found = NO;
    for (int i = height - 1; i > 0; i -= rowStep) {
      NSRange loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:(int *)STOP_PATTERN patternLen:STOP_PATTERN_LEN counters:counters2];
      if (loc.location != NSNotFound) {
        result[3] = [[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i];
        result[7] = [[ZXResultPoint alloc] initWithX:loc.location y:i];
        found = YES;
        break;
      }
    }
  }
  return found ? result : nil;
}

/**
 * Locate the vertices and the codewords area of a black blob using the Start
 * and Stop patterns as locators. This assumes that the image is rotated 180
 * degrees and if it locates the start and stop patterns at it will re-map
 * the vertices for a 0 degree rotation.
 *
 * Returns an array containing the vertices:
 * vertices[0] x, y top left barcode
 * vertices[1] x, y bottom left barcode
 * vertices[2] x, y top right barcode
 * vertices[3] x, y bottom right barcode
 * vertices[4] x, y top left codeword area
 * vertices[5] x, y bottom left codeword area
 * vertices[6] x, y top right codeword area
 * vertices[7] x, y bottom right codeword area
 */
- (NSMutableArray *)findVertices180:(ZXBitMatrix *)matrix rowStep:(int)rowStep {
  // TODO: Change assumption about barcode location.

  int height = matrix.height;
  int width = matrix.width;
  int halfWidth = width >> 1;

  NSMutableArray *result = [NSMutableArray arrayWithCapacity:16];
  for (int i = 0; i < 8; i++) {
    [result addObject:[NSNull null]];
  }
  BOOL found = NO;

  int counters[PDF417_START_PATTERN_LEN];
  memset(counters, 0, PDF417_START_PATTERN_LEN * sizeof(int));

  // Top Left
  for (int i = height - 1; i > 0; i -= rowStep) {
    NSRange loc = [self findGuardPattern:matrix column:halfWidth row:i width:halfWidth whiteFirst:YES pattern:(int *)START_PATTERN_REVERSE patternLen:START_PATTERN_REVERSE_LEN counters:counters];
    if (loc.location != NSNotFound) {
      result[0] = [[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i];
      result[4] = [[ZXResultPoint alloc] initWithX:loc.location y:i];
      found = YES;
      break;
    }
  }
  // Bottom Left
  if (found) { // Found the Top Left vertex
    found = NO;
    for (int i = 0; i < height; i += rowStep) {
      NSRange loc = [self findGuardPattern:matrix column:halfWidth row:i width:halfWidth whiteFirst:YES pattern:(int *)START_PATTERN_REVERSE patternLen:START_PATTERN_REVERSE_LEN counters:counters];
      if (loc.location != NSNotFound) {
        result[1] = [[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i];
        result[5] = [[ZXResultPoint alloc] initWithX:loc.location y:i];
        found = YES;
        break;
      }
    }
  }

  int counters2[STOP_PATTERN_LEN];
  memset(counters2, 0, STOP_PATTERN_LEN * sizeof(int));

  // Top Right
  if (found) { // Found the Bottom Left vertex
    found = NO;
    for (int i = height - 1; i > 0; i -= rowStep) {
      NSRange loc = [self findGuardPattern:matrix column:0 row:i width:halfWidth whiteFirst:NO pattern:(int *)STOP_PATTERN_REVERSE patternLen:STOP_PATTERN_REVERSE_LEN counters:counters2];
      if (loc.location != NSNotFound) {
        result[2] = [[ZXResultPoint alloc] initWithX:loc.location y:i];
        result[6] = [[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i];
        found = YES;
        break;
      }
    }
  }
  // Bottom Right
  if (found) { // Found the Top Right vertex
    found = NO;
    for (int i = 0; i < height; i += rowStep) {
      NSRange loc = [self findGuardPattern:matrix column:0 row:i width:halfWidth whiteFirst:NO pattern:(int *)STOP_PATTERN_REVERSE patternLen:STOP_PATTERN_REVERSE_LEN counters:counters2];
      if (loc.location != NSNotFound) {
        result[3] = [[ZXResultPoint alloc] initWithX:loc.location y:i];
        result[7] = [[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i];
        found = YES;
        break;
      }
    }
  }
  return found ? result : nil;
}

- (NSRange)findGuardPattern:(ZXBitMatrix *)matrix column:(int)column row:(int)row width:(int)width whiteFirst:(BOOL)whiteFirst pattern:(int *)pattern patternLen:(int)patternLen counters:(int *)counters {
  int patternLength = patternLen;
  memset(counters, 0, patternLength * sizeof(int));
  BOOL isWhite = whiteFirst;

  int counterPosition = 0;
  int patternStart = column;
  for (int x = column; x < column + width; x++) {
    BOOL pixel = [matrix getX:x y:row];
    if (pixel ^ isWhite) {
      counters[counterPosition] = counters[counterPosition] + 1;
    } else {
      if (counterPosition == patternLength - 1) {
        if ([self patternMatchVariance:counters countersSize:patternLength pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
          return NSMakeRange(patternStart, x - patternStart);
        }
        patternStart += counters[0] + counters[1];
        for (int y = 2; y < patternLength; y++) {
          counters[y - 2] = counters[y];
        }
        counters[patternLength - 2] = 0;
        counters[patternLength - 1] = 0;
        counterPosition--;
      } else {
        counterPosition++;
      }
      counters[counterPosition] = 1;
      isWhite = !isWhite;
    }
  }
  return NSMakeRange(NSNotFound, 0);
}

/**
 * Determines how closely a set of observed counts of runs of black/white
 * values matches a given target pattern. This is reported as the ratio of
 * the total variance from the expected pattern proportions across all
 * pattern elements, to the length of the pattern.
 */
- (int)patternMatchVariance:(int *)counters countersSize:(int)countersSize pattern:(int *)pattern maxIndividualVariance:(int)maxIndividualVariance {
  int numCounters = countersSize;
  int total = 0;
  int patternLength = 0;
  for (int i = 0; i < numCounters; i++) {
    total += counters[i];
    patternLength += pattern[i];
  }

  if (total < patternLength) {
    return INT_MAX;
  }
  int unitBarWidth = (total << PDF417_INTEGER_MATH_SHIFT) / patternLength;
  maxIndividualVariance = (maxIndividualVariance * unitBarWidth) >> 8;

  int totalVariance = 0;
  for (int x = 0; x < numCounters; x++) {
    int counter = counters[x] << PDF417_INTEGER_MATH_SHIFT;
    int scaledPattern = pattern[x] * unitBarWidth;
    int variance = counter > scaledPattern ? counter - scaledPattern : scaledPattern - counter;
    if (variance > maxIndividualVariance) {
      return INT_MAX;
    }
    totalVariance += variance;
  }

  return totalVariance / total;
}

/**
 * Correct the vertices by searching for top and bottom vertices of wide
 * bars, then locate the intersections between the upper and lower horizontal
 * line and the inner vertices vertical lines.
 */
- (BOOL)correctVertices:(ZXBitMatrix *)matrix vertices:(NSMutableArray *)vertices upsideDown:(BOOL)upsideDown {
  BOOL isLowLeft = ABS([vertices[4] y] - [vertices[5] y]) < 20.0;
  BOOL isLowRight = ABS([vertices[6] y] - [vertices[7] y]) < 20.0;
  if (isLowLeft || isLowRight) {
    return NO;
  } else {
    [self findWideBarTopBottom:matrix vertices:vertices offsetVertex:0 startWideBar:0  lenWideBar:8 lenPattern:17 rowStep:upsideDown ? 1 : -1];
    [self findWideBarTopBottom:matrix vertices:vertices offsetVertex:1 startWideBar:0  lenWideBar:8 lenPattern:17 rowStep:upsideDown ? -1 : 1];
    [self findWideBarTopBottom:matrix vertices:vertices offsetVertex:2 startWideBar:11 lenWideBar:7 lenPattern:18 rowStep:upsideDown ? 1 : -1];
    [self findWideBarTopBottom:matrix vertices:vertices offsetVertex:3 startWideBar:11 lenWideBar:7 lenPattern:18 rowStep:upsideDown ? -1 : 1];
    if (![self findCrossingPoint:vertices idxResult:12 idxLineA1:4 idxLineA2:5 idxLineB1:8 idxLineB2:10 matrix:matrix]) {
      return NO;
    }
    if (![self findCrossingPoint:vertices idxResult:13 idxLineA1:4 idxLineA2:5 idxLineB1:9 idxLineB2:11 matrix:matrix]) {
      return NO;
    }
    if (![self findCrossingPoint:vertices idxResult:14 idxLineA1:6 idxLineA2:7 idxLineB1:8 idxLineB2:10 matrix:matrix]) {
      return NO;
    }
    if (![self findCrossingPoint:vertices idxResult:15 idxLineA1:6 idxLineA2:7 idxLineB1:9 idxLineB2:11 matrix:matrix]) {
      return NO;
    }
    return YES;
  }
}

/**
 * Locate the top or bottom of one of the two wide black bars of a guard pattern.
 *
 * Warning: it only searches along the y axis, so the return points would not be
 * right if the barcode is too curved.
 */
- (void)findWideBarTopBottom:(ZXBitMatrix *)matrix
                    vertices:(NSMutableArray *)vertices
                offsetVertex:(int)offsetVertex
                startWideBar:(int)startWideBar
                  lenWideBar:(int)lenWideBar
                  lenPattern:(int)lenPattern
                     rowStep:(int)rowStep {
  ZXResultPoint *verticeStart = vertices[offsetVertex];
  ZXResultPoint *verticeEnd = vertices[offsetVertex + 4];

  // Start horizontally at the middle of the bar.
  int endWideBar = startWideBar + lenWideBar;
  float barDiff = verticeEnd.x - verticeStart.x;
  float barStart = verticeStart.x + (barDiff * startWideBar) / lenPattern;
  float barEnd = verticeStart.x + (barDiff * endWideBar) / lenPattern;
  int x = (int)roundf((barStart + barEnd) / 2.0f);

  // Start vertically between the preliminary vertices.
  int yStart = (int)roundf(verticeStart.y);
  int y = yStart;

  // Find offset of thin bar to the right as additional safeguard.
  int nextBarX = (int)fmaxf(barStart, barEnd) + 1;
  while (nextBarX < matrix.width) {
    if (![matrix getX:nextBarX - 1 y:y] && [matrix getX:nextBarX y:y]) {
      break;
    }
    nextBarX++;
  }
  nextBarX -= x;

  BOOL isEnd = NO;
  while (!isEnd) {
    if ([matrix getX:x y:y]) {
      // If the thin bar to the right ended, stop as well
      isEnd = ![matrix getX:x + nextBarX y:y] && ![matrix getX:x + nextBarX + 1 y:y];
      y += rowStep;
      if (y <= 0 || y >= matrix.height - 1) {
        // End of barcode image reached.
        isEnd = YES;
      }
    } else {
      // Look sidewise whether black bar continues? (in the case the image is skewed)
      if (x > 0 && [matrix getX:x - 1 y:y]) {
        x--;
      } else if (x < matrix.width - 1 && [matrix getX:x + 1 y:y]) {
        x++;
      } else {
        // End of pattern regarding big bar and big gap reached.
        isEnd = YES;
        if (y != yStart) {
          // Turn back one step, because target has been exceeded.
          y -= rowStep;
        }
      }
    }
  }

  vertices[offsetVertex + 8] = [[ZXResultPoint alloc] initWithX:x y:y];
}

/**
 * Finds the intersection of two lines.
 */
- (BOOL)findCrossingPoint:(NSMutableArray *)vertices
                idxResult:(int)idxResult
                idxLineA1:(int)idxLineA1
                idxLineA2:(int)idxLineA2
                idxLineB1:(int)idxLineB1
                idxLineB2:(int)idxLineB2
                   matrix:(ZXBitMatrix *)matrix {
  ZXResultPoint *result = [self intersection:vertices[idxLineA1] a2:vertices[idxLineA2] b1:vertices[idxLineB1] b2:vertices[idxLineB2]];
  if (!result) {
    return NO;
  }

  int x = (int)roundf(result.x);
  int y = (int)roundf(result.y);
  if (x < 0 || x >= matrix.width || y < 0 || y >= matrix.height) {
    return NO;
  }

  vertices[idxResult] = result;
  return YES;
}

/**
 * Computes the intersection between two lines.
 */
- (ZXResultPoint *)intersection:(ZXResultPoint *)a1 a2:(ZXResultPoint *)a2 b1:(ZXResultPoint *)b1 b2:(ZXResultPoint *)b2 {
  float dxa = a1.x - a2.x;
  float dxb = b1.x - b2.x;
  float dya = a1.y - a2.y;
  float dyb = b1.y - b2.y;

  float p = a1.x * a2.y - a1.y * a2.x;
  float q = b1.x * b2.y - b1.y * b2.x;
  float denom = dxa * dyb - dya * dxb;
  if (denom == 0) {
    // Lines don't intersect
    return nil;
  }

  float x = (p * dxb - dxa * q) / denom;
  float y = (p * dyb - dya * q) / denom;

  return [[ZXResultPoint alloc] initWithX:x y:y];
}

/**
 * Estimates module size (pixels in a module) based on the Start and End
 * finder patterns.
 *
 * Vertices is an array of vertices:
 * vertices[0] x, y top left barcode
 * vertices[1] x, y bottom left barcode
 * vertices[2] x, y top right barcode
 * vertices[3] x, y bottom right barcode
 * vertices[4] x, y top left codeword area
 * vertices[5] x, y bottom left codeword area
 * vertices[6] x, y top right codeword area
 * vertices[7] x, y bottom right codeword area
 */
- (float)computeModuleWidth:(NSArray *)vertices {
  float pixels1 = [ZXResultPoint distance:vertices[0] pattern2:vertices[4]];
  float pixels2 = [ZXResultPoint distance:vertices[1] pattern2:vertices[5]];
  float moduleWidth1 = (pixels1 + pixels2) / (17 * 2.0f);
  float pixels3 = [ZXResultPoint distance:vertices[6] pattern2:vertices[2]];
  float pixels4 = [ZXResultPoint distance:vertices[7] pattern2:vertices[3]];
  float moduleWidth2 = (pixels3 + pixels4) / (18 * 2.0f);
  return (moduleWidth1 + moduleWidth2) / 2.0f;
}

/**
 * Computes the dimension (number of modules in a row) of the PDF417 Code
 * based on vertices of the codeword area and estimated module size.
 */
- (int)computeDimension:(ZXResultPoint *)topLeft
               topRight:(ZXResultPoint *)topRight
             bottomLeft:(ZXResultPoint *)bottomLeft
            bottomRight:(ZXResultPoint *)bottomRight
            moduleWidth:(float)moduleWidth {
  int topRowDimension = [ZXMathUtils round:[ZXResultPoint distance:topLeft pattern2:topRight] / moduleWidth];
  int bottomRowDimension = [ZXMathUtils round:[ZXResultPoint distance:bottomLeft pattern2:bottomRight] / moduleWidth];
  return ((((topRowDimension + bottomRowDimension) >> 1) + 8) / 17) * 17;
}

/**
 * Computes the y dimension (number of modules in a column) of the PDF417 Code
 * based on vertices of the codeword area and estimated module size.
 */
- (int)computeYDimension:(ZXResultPoint *)topLeft topRight:(ZXResultPoint *)topRight bottomLeft:(ZXResultPoint *)bottomLeft bottomRight:(ZXResultPoint *)bottomRight moduleWidth:(float)moduleWidth {
  int leftColumnDimension = [ZXMathUtils round:[ZXResultPoint distance:topLeft pattern2:bottomLeft] / moduleWidth];
  int rightColumnDimension = [ZXMathUtils round:[ZXResultPoint distance:topRight pattern2:bottomRight] / moduleWidth];
  return (leftColumnDimension + rightColumnDimension) >> 1;
}

/**
 * Deskew and over-sample image.
 */
- (ZXBitMatrix *)sampleLines:(NSMutableArray *)vertices dimension:(int)dimension yDimension:(int)yDimension {
  int sampleDimensionX = dimension * 8;
  int sampleDimensionY = yDimension * 4;

  ZXPerspectiveTransform *transform = [ZXPerspectiveTransform quadrilateralToQuadrilateral:0.0f y0:0.0f
                                                                                       x1:sampleDimensionX y1:0.0f
                                                                                       x2:0.0f y2:sampleDimensionY
                                                                                       x3:sampleDimensionX y3:sampleDimensionY
                                                                                      x0p:[vertices[12] x] y0p:[vertices[12] y]
                                                                                      x1p:[vertices[14] x] y1p:[vertices[14] y]
                                                                                      x2p:[vertices[13] x] y2p:[vertices[13] y]
                                                                                      x3p:[vertices[15] x] y3p:[vertices[15] y]];

  ZXBitMatrix *blackMatrix = [self.image blackMatrixWithError:nil];
  if (!blackMatrix) {
    return nil;
  }

  return [[ZXGridSampler instance] sampleGrid:blackMatrix dimensionX:sampleDimensionX dimensionY:sampleDimensionY transform:transform error:nil];
}

@end

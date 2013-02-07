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
#import "ZXMathUtils.h"
#import "ZXPDF417Detector.h"
#import "ZXResultPoint.h"

int const PDF417_INTEGER_MATH_SHIFT = 8;
int const PDF417_PATTERN_MATCH_RESULT_SCALE_FACTOR = 1 << PDF417_INTEGER_MATH_SHIFT;
int const MAX_AVG_VARIANCE = (int) (PDF417_PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.42f);
int const MAX_INDIVIDUAL_VARIANCE = (int) (PDF417_PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.8f);
int const SKEW_THRESHOLD = 3;

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

@property (nonatomic, retain) ZXBinaryBitmap *image;

- (NSMutableArray *)findVertices:(ZXBitMatrix *)matrix tryHarder:(BOOL)tryHarder;
- (NSMutableArray *)findVertices180:(ZXBitMatrix *)matrix tryHarder:(BOOL)tryHarder;
- (void)correctCodeWordVertices:(NSMutableArray *)vertices upsideDown:(BOOL)upsideDown;
- (float)computeModuleWidth:(NSArray *)vertices;
- (int)computeDimension:(ZXResultPoint *)topLeft topRight:(ZXResultPoint *)topRight bottomLeft:(ZXResultPoint *)bottomLeft bottomRight:(ZXResultPoint *)bottomRight moduleWidth:(float)moduleWidth;
- (int)computeYDimension:(ZXResultPoint *)topLeft topRight:(ZXResultPoint *)topRight bottomLeft:(ZXResultPoint *)bottomLeft bottomRight:(ZXResultPoint *)bottomRight moduleWidth:(float)moduleWidth;
- (NSRange)findGuardPattern:(ZXBitMatrix *)matrix column:(int)column row:(int)row width:(int)width whiteFirst:(BOOL)whiteFirst pattern:(int *)pattern patternLen:(int)patternLen counters:(int *)counters;
- (int)patternMatchVariance:(int *)counters countersSize:(int)countersSize pattern:(int *)pattern maxIndividualVariance:(int)maxIndividualVariance;
- (ZXBitMatrix *)sampleGrid:(ZXBitMatrix *)matrix
                    topLeft:(ZXResultPoint *)topLeft
                 bottomLeft:(ZXResultPoint *)bottomLeft
                   topRight:(ZXResultPoint *)topRight
                bottomRight:(ZXResultPoint *)bottomRight
                 xdimension:(int)xdimension
                 ydimension:(int)ydimension
                      error:(NSError **)error;

@end


@implementation ZXPDF417Detector

@synthesize image;

- (id)initWithImage:(ZXBinaryBitmap *)anImage {
  if (self = [super init]) {
    self.image = anImage;
  }

  return self;
}

- (void)dealloc {
  [image release];

  [super dealloc];
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

  BOOL tryHarder = hints != nil && hints.tryHarder;

  // Try to find the vertices assuming the image is upright.
  NSMutableArray *vertices = [self findVertices:matrix tryHarder:tryHarder];
  if (vertices == nil) {
    // Maybe the image is rotated 180 degrees?
    vertices = [self findVertices180:matrix tryHarder:tryHarder];
    if (vertices != nil) {
      [self correctCodeWordVertices:vertices upsideDown:YES];
    }
  } else {
    [self correctCodeWordVertices:vertices upsideDown:NO];
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

  int dimension = [self computeDimension:[vertices objectAtIndex:4]
                                topRight:[vertices objectAtIndex:6]
                              bottomLeft:[vertices objectAtIndex:5]
                             bottomRight:[vertices objectAtIndex:7]
                             moduleWidth:moduleWidth];
  if (dimension < 1) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  int ydimension = [self computeYDimension:[vertices objectAtIndex:4]
                                  topRight:[vertices objectAtIndex:6]
                                bottomLeft:[vertices objectAtIndex:5]
                               bottomRight:[vertices objectAtIndex:7]
                               moduleWidth:moduleWidth];
  ydimension = ydimension > dimension ? ydimension : dimension;

  // Deskew and sample image.
  ZXBitMatrix *bits = [self sampleGrid:matrix
                               topLeft:[vertices objectAtIndex:4]
                            bottomLeft:[vertices objectAtIndex:5]
                              topRight:[vertices objectAtIndex:6]
                           bottomRight:[vertices objectAtIndex:7]
                            xdimension:dimension
                            ydimension:ydimension
                                 error:error];
  if (!bits) {
    return nil;
  }
  return [[[ZXDetectorResult alloc] initWithBits:bits
                                          points:[NSArray arrayWithObjects:[vertices objectAtIndex:5],
                                                  [vertices objectAtIndex:4], [vertices objectAtIndex:6],
                                                  [vertices objectAtIndex:7], nil]] autorelease];
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
- (NSMutableArray *)findVertices:(ZXBitMatrix *)matrix tryHarder:(BOOL)tryHarder {
  int height = matrix.height;
  int width = matrix.width;

  NSMutableArray *result = [NSMutableArray arrayWithCapacity:8];
  for (int i = 0; i < 8; i++) {
    [result addObject:[NSNull null]];
  }
  BOOL found = NO;

  int counters[START_PATTERN_REVERSE_LEN];
  memset(counters, 0, START_PATTERN_REVERSE_LEN * sizeof(int));

  int rowStep = MAX(1, height >> (tryHarder ? 9 : 7));

  // Top Left
  for (int i = 0; i < height; i += rowStep) {
    NSRange loc = [self findGuardPattern:matrix column:0 row:i width:width whiteFirst:NO pattern:(int *)PDF417_START_PATTERN patternLen:PDF417_START_PATTERN_LEN counters:counters];
    if (loc.location != NSNotFound) {
      [result replaceObjectAtIndex:0 withObject:[[[ZXResultPoint alloc] initWithX:loc.location y:i] autorelease]];
      [result replaceObjectAtIndex:4 withObject:[[[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i] autorelease]];
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
        [result replaceObjectAtIndex:1 withObject:[[[ZXResultPoint alloc] initWithX:loc.location y:i] autorelease]];
        [result replaceObjectAtIndex:5 withObject:[[[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i] autorelease]];
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
        [result replaceObjectAtIndex:2 withObject:[[[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i] autorelease]];
        [result replaceObjectAtIndex:6 withObject:[[[ZXResultPoint alloc] initWithX:loc.location y:i] autorelease]];
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
        [result replaceObjectAtIndex:3 withObject:[[[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i] autorelease]];
        [result replaceObjectAtIndex:7 withObject:[[[ZXResultPoint alloc] initWithX:loc.location y:i] autorelease]];
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
 * TODO: Change assumption about barcode location.
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
- (NSMutableArray *)findVertices180:(ZXBitMatrix *)matrix tryHarder:(BOOL)tryHarder {
  int height = matrix.height;
  int width = matrix.width;
  int halfWidth = width >> 1;

  NSMutableArray *result = [NSMutableArray arrayWithCapacity:8];
  for (int i = 0; i < 8; i++) {
    [result addObject:[NSNull null]];
  }
  BOOL found = NO;

  int counters[PDF417_START_PATTERN_LEN];
  memset(counters, 0, PDF417_START_PATTERN_LEN * sizeof(int));

  int rowStep = MAX(1, height >> (tryHarder ? 9 : 7));

  // Top Left
  for (int i = height - 1; i > 0; i -= rowStep) {
    NSRange loc = [self findGuardPattern:matrix column:halfWidth row:i width:halfWidth whiteFirst:YES pattern:(int *)START_PATTERN_REVERSE patternLen:START_PATTERN_REVERSE_LEN counters:counters];
    if (loc.location != NSNotFound) {
      [result replaceObjectAtIndex:0 withObject:[[[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i] autorelease]];
      [result replaceObjectAtIndex:4 withObject:[[[ZXResultPoint alloc] initWithX:loc.location y:i] autorelease]];
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
        [result replaceObjectAtIndex:1 withObject:[[[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i] autorelease]];
        [result replaceObjectAtIndex:5 withObject:[[[ZXResultPoint alloc] initWithX:loc.location y:i] autorelease]];
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
        [result replaceObjectAtIndex:2 withObject:[[[ZXResultPoint alloc] initWithX:loc.location y:i] autorelease]];
        [result replaceObjectAtIndex:6 withObject:[[[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i] autorelease]];
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
        [result replaceObjectAtIndex:3 withObject:[[[ZXResultPoint alloc] initWithX:loc.location y:i] autorelease]];
        [result replaceObjectAtIndex:7 withObject:[[[ZXResultPoint alloc] initWithX:NSMaxRange(loc) y:i] autorelease]];
        found = YES;
        break;
      }
    }
  }
  return found ? result : nil;
}


/**
 * Because we scan horizontally to detect the start and stop patterns, the vertical component of
 * the codeword coordinates will be slightly wrong if there is any skew or rotation in the image.
 * This method moves those points back onto the edges of the theoretically perfect bounding
 * quadrilateral if needed.
 */
- (void)correctCodeWordVertices:(NSMutableArray *)vertices upsideDown:(BOOL)upsideDown {
  float v0x = [(ZXResultPoint *)[vertices objectAtIndex:0] x];
  float v0y = [(ZXResultPoint *)[vertices objectAtIndex:0] y];
  float v2x = [(ZXResultPoint *)[vertices objectAtIndex:2] x];
  float v2y = [(ZXResultPoint *)[vertices objectAtIndex:2] y];
  float v4x = [(ZXResultPoint *)[vertices objectAtIndex:4] x];
  float v4y = [(ZXResultPoint *)[vertices objectAtIndex:4] y];
  float v6x = [(ZXResultPoint *)[vertices objectAtIndex:6] x];
  float v6y = [(ZXResultPoint *)[vertices objectAtIndex:6] y];

  float skew = v4y - v6y;
  if (upsideDown) {
    skew = -skew;
  }
  if (skew > SKEW_THRESHOLD) {
    // Fix v4
    float deltax = v6x - v0x;
    float deltay = v6y - v0y;
    float delta2 = deltax * deltax + deltay * deltay;
    float correction = (v4x - v0x) * deltax / delta2;
    [vertices replaceObjectAtIndex:4
                        withObject:[[[ZXResultPoint alloc] initWithX:v0x + correction * deltax
                                                                   y:v0y + correction * deltay] autorelease]];
  } else if (-skew > SKEW_THRESHOLD) {
    // Fix v6
    float deltax = v2x - v4x;
    float deltay = v2y - v4y;
    float delta2 = deltax * deltax + deltay * deltay;
    float correction = (v2x - v6x) * deltax / delta2;
    [vertices replaceObjectAtIndex:6
                        withObject:[[[ZXResultPoint alloc] initWithX:v2x - correction * deltax
                                                                   y:v2y - correction * deltay] autorelease]];
  }
  
  float v1x = [(ZXResultPoint *)[vertices objectAtIndex:1] x];
  float v1y = [(ZXResultPoint *)[vertices objectAtIndex:1] y];
  float v3x = [(ZXResultPoint *)[vertices objectAtIndex:3] x];
  float v3y = [(ZXResultPoint *)[vertices objectAtIndex:3] y];
  float v5x = [(ZXResultPoint *)[vertices objectAtIndex:5] x];
  float v5y = [(ZXResultPoint *)[vertices objectAtIndex:5] y];
  float v7x = [(ZXResultPoint *)[vertices objectAtIndex:7] x];
  float v7y = [(ZXResultPoint *)[vertices objectAtIndex:7] y];

  skew = v7y - v5y;
  if (upsideDown) {
    skew = -skew;
  }
  if (skew > SKEW_THRESHOLD) {
    // Fix v5
    float deltax = v7x - v1x;
    float deltay = v7y - v1y;
    float delta2 = deltax * deltax + deltay * deltay;
    float correction = (v5x - v1x) * deltax / delta2;
    [vertices replaceObjectAtIndex:5
                        withObject:[[[ZXResultPoint alloc] initWithX:v1x + correction * deltax
                                                                   y:v1y + correction * deltay] autorelease]];
  } else if (-skew > SKEW_THRESHOLD) {
    // Fix v7
    float deltax = v3x - v5x;
    float deltay = v3y - v5y;
    float delta2 = deltax * deltax + deltay * deltay;
    float correction = (v3x - v7x) * deltax / delta2;
    [vertices replaceObjectAtIndex:7
                        withObject:[[[ZXResultPoint alloc] initWithX:v3x - correction * deltax
                                                                   y:v3y - correction * deltay] autorelease]];
  }
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
  float pixels1 = [ZXResultPoint distance:[vertices objectAtIndex:0] pattern2:[vertices objectAtIndex:4]];
  float pixels2 = [ZXResultPoint distance:[vertices objectAtIndex:1] pattern2:[vertices objectAtIndex:5]];
  float moduleWidth1 = (pixels1 + pixels2) / (17 * 2.0f);
  float pixels3 = [ZXResultPoint distance:[vertices objectAtIndex:6] pattern2:[vertices objectAtIndex:2]];
  float pixels4 = [ZXResultPoint distance:[vertices objectAtIndex:7] pattern2:[vertices objectAtIndex:3]];
  float moduleWidth2 = (pixels3 + pixels4) / (18 * 2.0f);
  return (moduleWidth1 + moduleWidth2) / 2.0f;
}


/**
 * Computes the dimension (number of modules in a row) of the PDF417 Code
 * based on vertices of the codeword area and estimated module size.
 */
- (int)computeDimension:(ZXResultPoint *)topLeft topRight:(ZXResultPoint *)topRight bottomLeft:(ZXResultPoint *)bottomLeft bottomRight:(ZXResultPoint *)bottomRight moduleWidth:(float)moduleWidth {
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

- (ZXBitMatrix *)sampleGrid:(ZXBitMatrix *)matrix
                    topLeft:(ZXResultPoint *)topLeft
                 bottomLeft:(ZXResultPoint *)bottomLeft
                   topRight:(ZXResultPoint *)topRight
                bottomRight:(ZXResultPoint *)bottomRight
                 xdimension:(int)xdimension
                 ydimension:(int)ydimension
                      error:(NSError **)error {
  ZXGridSampler *sampler = [ZXGridSampler instance];
  return [sampler sampleGrid:matrix
                  dimensionX:xdimension
                  dimensionY:ydimension
                       p1ToX:0.0f
                       p1ToY:0.0f
                       p2ToX:xdimension
                       p2ToY:0.0f
                       p3ToX:xdimension
                       p3ToY:ydimension
                       p4ToX:0.0f
                       p4ToY:ydimension
                     p1FromX:[topLeft x]
                     p1FromY:[topLeft y]
                     p2FromX:[topRight x]
                     p2FromY:[topRight y]
                     p3FromX:[bottomRight x]
                     p3FromY:[bottomRight y]
                     p4FromX:[bottomLeft x]
                     p4FromY:[bottomLeft y]
                       error:error];
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
    return NSIntegerMax;
  }
  int unitBarWidth = (total << PDF417_INTEGER_MATH_SHIFT) / patternLength;
  maxIndividualVariance = (maxIndividualVariance * unitBarWidth) >> 8;

  int totalVariance = 0;
  for (int x = 0; x < numCounters; x++) {
    int counter = counters[x] << PDF417_INTEGER_MATH_SHIFT;
    int scaledPattern = pattern[x] * unitBarWidth;
    int variance = counter > scaledPattern ? counter - scaledPattern : scaledPattern - counter;
    if (variance > maxIndividualVariance) {
      return NSIntegerMax;
    }
    totalVariance += variance;
  }

  return totalVariance / total;
}

@end

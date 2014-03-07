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

#import "ZXAztecDetector.h"
#import "ZXAztecDetectorResult.h"
#import "ZXErrors.h"
#import "ZXGenericGF.h"
#import "ZXGridSampler.h"
#import "ZXMathUtils.h"
#import "ZXReedSolomonDecoder.h"
#import "ZXResultPoint.h"
#import "ZXWhiteRectangleDetector.h"

@interface ZXAztecPoint : NSObject

@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;

@end

@implementation ZXAztecPoint

- (id)initWithX:(int)x y:(int)y {
  if (self = [super init]) {
    _x = x;
    _y = y;
  }
  return self;
}

- (ZXResultPoint *)toResultPoint {
  return [[ZXResultPoint alloc] initWithX:self.x y:self.y];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%d %d>", self.x, self.y];
}

@end

@interface ZXAztecDetector ()

@property (nonatomic, assign) BOOL compact;
@property (nonatomic, strong) ZXBitMatrix *image;
@property (nonatomic, assign) int nbCenterLayers;
@property (nonatomic, assign) int nbDataBlocks;
@property (nonatomic, assign) int nbLayers;
@property (nonatomic, assign) int shift;

@end

@implementation ZXAztecDetector

- (id)initWithImage:(ZXBitMatrix *)image {
  if (self = [super init]) {
    _image = image;
  }
  return self;
}

/**
 * Detects an Aztec Code in an image.
 */
- (ZXAztecDetectorResult *)detectWithError:(NSError **)error {
  // 1. Get the center of the aztec matrix
  ZXAztecPoint *pCenter = [self matrixCenterWithError:error];
  if (!pCenter) {
    return nil;
  }

  // 2. Get the center points of the four diagonal points just outside the bull's eye
  //  [topRight, bottomRight, bottomLeft, topLeft]
  NSArray *bullsEyeCorners = [self bullsEyeCorners:pCenter];
  if (!bullsEyeCorners) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  // 3. Get the size of the matrix and other parameters from the bull's eye
  if (![self extractParameters:bullsEyeCorners error:error]) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  // 4. Sample the grid
  ZXBitMatrix *bits = [self sampleGrid:self.image
                               topLeft:bullsEyeCorners[self.shift % 4]
                              topRight:bullsEyeCorners[(self.shift + 1) % 4]
                           bottomRight:bullsEyeCorners[(self.shift + 2) % 4]
                            bottomLeft:bullsEyeCorners[(self.shift + 3) % 4]
                                 error:error];

  // 5. Get the corners of the matrix.
  NSArray *corners = [self matrixCornerPoints:bullsEyeCorners];
  if (!corners) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  return [[ZXAztecDetectorResult alloc] initWithBits:bits
                                               points:corners
                                              compact:self.compact
                                         nbDatablocks:self.nbDataBlocks
                                             nbLayers:self.nbLayers];
}


/**
 * Extracts the number of data layers and data blocks from the layer around the bull's eye
 */
- (BOOL)extractParameters:(NSArray *)bullsEyeCorners error:(NSError **)error {
  ZXResultPoint *p0 = bullsEyeCorners[0];
  ZXResultPoint *p1 = bullsEyeCorners[1];
  ZXResultPoint *p2 = bullsEyeCorners[2];
  ZXResultPoint *p3 = bullsEyeCorners[3];

  if (![self isValid:p0] || ![self isValid:p1] ||
      ![self isValid:p2] || ![self isValid:p3]) {
    return NO;
  }
  int twoCenterLayers = 2 * self.nbCenterLayers;

  // Get the bits around the bull's eye
  NSArray *resab = [self sampleLine:p0 p2:p1 size:twoCenterLayers + 1];
  NSArray *resbc = [self sampleLine:p1 p2:p2 size:twoCenterLayers + 1];
  NSArray *rescd = [self sampleLine:p2 p2:p3 size:twoCenterLayers + 1];
  NSArray *resda = [self sampleLine:p3 p2:p0 size:twoCenterLayers + 1];

  // Determine the orientation of the matrix
  if ([resab[0] boolValue] && [resab[twoCenterLayers] boolValue]) {
    self.shift = 0;
  } else if ([resbc[0] boolValue] && [resbc[twoCenterLayers] boolValue]) {
    self.shift = 1;
  } else if ([rescd[0] boolValue] && [rescd[twoCenterLayers] boolValue]) {
    self.shift = 2;
  } else if ([resda[0] boolValue] && [resda[twoCenterLayers] boolValue]) {
    self.shift = 3;
  } else {
    if (error) *error = NotFoundErrorInstance();
    return NO;
  }

  //d      a
  //
  //c      b

  // Flatten the bits in a single array
  NSMutableArray *parameterData = [NSMutableArray array];
  NSMutableArray *shiftedParameterData = [NSMutableArray array];
  if (self.compact) {
    for (int i = 0; i < 28; i++) {
      [shiftedParameterData addObject:@NO];
    }

    for (int i = 0; i < 7; i++) {
      shiftedParameterData[i] = resab[2+i];
      shiftedParameterData[i + 7] = resbc[2+i];
      shiftedParameterData[i + 14] = rescd[2+i];
      shiftedParameterData[i + 21] = resda[2+i];
    }

    for (int i = 0; i < 28; i++) {
      [parameterData addObject:shiftedParameterData[(i + self.shift * 7) % 28]];
    }
  } else {
    for (int i = 0; i < 40; i++) {
      [shiftedParameterData addObject:@NO];
    }

    for (int i = 0; i < 11; i++) {
      if (i < 5) {
        shiftedParameterData[i] = resab[2 + i];
        shiftedParameterData[i + 10] = resbc[2 + i];
        shiftedParameterData[i + 20] = rescd[2 + i];
        shiftedParameterData[i + 30] = resda[2 + i];
      }
      if (i > 5) {
        shiftedParameterData[i - 1] = resab[2 + i];
        shiftedParameterData[i + 9] = resbc[2 + i];
        shiftedParameterData[i + 19] = rescd[2 + i];
        shiftedParameterData[i + 29] = resda[2 + i];
      }
    }

    for (int i = 0; i < 40; i++) {
      [parameterData addObject:shiftedParameterData[(i + self.shift * 10) % 40]];
    }
  }

  // corrects the error using RS algorithm
  if (![self correctParameterData:parameterData compact:self.compact error:error]) {
    return NO;
  }

  // gets the parameters from the bit array
  [self parameters:parameterData];
  return YES;
}

/**
 * Gets the Aztec code corners from the bull's eye corners and the parameters
 */
- (NSArray *)matrixCornerPoints:(NSArray *)bullsEyeCorners {
  return [self expandSquare:bullsEyeCorners oldSide:2 * self.nbCenterLayers newSide:[self dimension]];
}

/**
 * Corrects the parameter bits using Reed-Solomon algorithm.
 */
- (BOOL)correctParameterData:(NSMutableArray *)parameterData compact:(BOOL)isCompact error:(NSError **)error {
  int numCodewords;
  int numDataCodewords;

  if (isCompact) {
    numCodewords = 7;
    numDataCodewords = 2;
  } else {
    numCodewords = 10;
    numDataCodewords = 4;
  }

  int numECCodewords = numCodewords - numDataCodewords;
  int parameterWordsLen = numCodewords;
  int parameterWords[parameterWordsLen];

  int codewordSize = 4;
  for (int i = 0; i < parameterWordsLen; i++) {
    parameterWords[i] = 0;
    int flag = 1;
    for (int j = 1; j <= codewordSize; j++) {
      if ([parameterData[codewordSize * i + codewordSize - j] boolValue]) {
        parameterWords[i] += flag;
      }
      flag <<= 1;
    }
  }

  ZXReedSolomonDecoder *rsDecoder = [[ZXReedSolomonDecoder alloc] initWithField:[ZXGenericGF AztecParam]];
  NSError *decodeError = nil;
  if (![rsDecoder decode:parameterWords receivedLen:parameterWordsLen twoS:numECCodewords error:error]) {
    if (decodeError.code == ZXReedSolomonError) {
      if (error) *error = NotFoundErrorInstance();
      return NO;
    } else {
      return NO;
    }
  }

  for (int i = 0; i < numDataCodewords; i++) {
    int flag = 1;
    for (int j = 1; j <= codewordSize; j++) {
      parameterData[i * codewordSize + codewordSize - j] = [NSNumber numberWithBool:(parameterWords[i] & flag) == flag];
      flag <<= 1;
    }
  }
  return YES;
}

/**
 * Finds the corners of a bull-eye centered on the passed point.
 * This returns the centers of the diagonal points just outside the bull's eye
 * Returns [topRight, bottomRight, bottomLeft, topLeft]
 */
- (NSArray *)bullsEyeCorners:(ZXAztecPoint *)pCenter {
  ZXAztecPoint *pina = pCenter;
  ZXAztecPoint *pinb = pCenter;
  ZXAztecPoint *pinc = pCenter;
  ZXAztecPoint *pind = pCenter;

  BOOL color = YES;

  for (self.nbCenterLayers = 1; self.nbCenterLayers < 9; self.nbCenterLayers++) {
    ZXAztecPoint *pouta = [self firstDifferent:pina color:color dx:1 dy:-1];
    ZXAztecPoint *poutb = [self firstDifferent:pinb color:color dx:1 dy:1];
    ZXAztecPoint *poutc = [self firstDifferent:pinc color:color dx:-1 dy:1];
    ZXAztecPoint *poutd = [self firstDifferent:pind color:color dx:-1 dy:-1];

    //d      a
    //
    //c      b

    if (self.nbCenterLayers > 2) {
      float q = [self distance:poutd b:pouta] * self.nbCenterLayers / ([self distance:pind b:pina] * (self.nbCenterLayers + 2));
      if (q < 0.75 || q > 1.25 || ![self isWhiteOrBlackRectangle:pouta p2:poutb p3:poutc p4:poutd]) {
        break;
      }
    }

    pina = pouta;
    pinb = poutb;
    pinc = poutc;
    pind = poutd;

    color = !color;
  }

  if (self.nbCenterLayers != 5 && self.nbCenterLayers != 7) {
    return nil;
  }

  self.compact = self.nbCenterLayers == 5;

  // Expand the square by .5 pixel in each direction so that we're on the border
  // between the white square and the black square
  ZXResultPoint *pinax = [[ZXResultPoint alloc] initWithX:pina.x + 0.5f y:pina.y - 0.5f];
  ZXResultPoint *pinbx = [[ZXResultPoint alloc] initWithX:pinb.x + 0.5f y:pinb.y + 0.5f];
  ZXResultPoint *pincx = [[ZXResultPoint alloc] initWithX:pinc.x - 0.5f y:pinc.y + 0.5f];
  ZXResultPoint *pindx = [[ZXResultPoint alloc] initWithX:pind.x - 0.5f y:pind.y - 0.5f];

  // Expand the square so that its corners are the centers of the points
  // just outside the bull's eye.
  return [self expandSquare:@[pinax, pinbx, pincx, pindx]
                    oldSide:2 * self.nbCenterLayers - 3
                    newSide:2 * self.nbCenterLayers];
}

/**
 * Finds a candidate center point of an Aztec code from an image
 */
- (ZXAztecPoint *)matrixCenterWithError:(NSError **)error {
  ZXResultPoint *pointA;
  ZXResultPoint *pointB;
  ZXResultPoint *pointC;
  ZXResultPoint *pointD;

  NSError *detectorError = nil;
  ZXWhiteRectangleDetector *detector = [[ZXWhiteRectangleDetector alloc] initWithImage:self.image error:&detectorError];
  NSArray *cornerPoints = nil;
  if (detector) {
    cornerPoints = [detector detectWithError:&detectorError];
  }

  if (detectorError && detectorError.code == ZXNotFoundError) {
    int cx = self.image.width / 2;
    int cy = self.image.height / 2;
    pointA = [[self firstDifferent:[[ZXAztecPoint alloc] initWithX:cx + 7 y:cy - 7] color:NO dx:1 dy:-1] toResultPoint];
    pointB = [[self firstDifferent:[[ZXAztecPoint alloc] initWithX:cx + 7 y:cy + 7]  color:NO dx:1 dy:1] toResultPoint];
    pointC = [[self firstDifferent:[[ZXAztecPoint alloc] initWithX:cx - 7 y:cy + 7]  color:NO dx:-1 dy:1] toResultPoint];
    pointD = [[self firstDifferent:[[ZXAztecPoint alloc] initWithX:cx - 7 y:cy - 7]  color:NO dx:-1 dy:-1] toResultPoint];
  } else if (detectorError) {
    if (error) *error = detectorError;
    return nil;
  } else {
    pointA = cornerPoints[0];
    pointB = cornerPoints[1];
    pointC = cornerPoints[2];
    pointD = cornerPoints[3];
  }

  int cx = [ZXMathUtils round:([pointA x] + [pointD x] + [pointB x] + [pointC x]) / 4.0f];
  int cy = [ZXMathUtils round:([pointA y] + [pointD y] + [pointB y] + [pointC y]) / 4.0f];

  detectorError = nil;
  detector = [[ZXWhiteRectangleDetector alloc] initWithImage:self.image initSize:15 x:cx y:cy error:&detectorError];
  if (detector) {
    cornerPoints = [detector detectWithError:&detectorError];
  }

  if (detectorError && detectorError.code == ZXNotFoundError) {
    pointA = [[self firstDifferent:[[ZXAztecPoint alloc] initWithX:cx + 7 y:cy - 7]  color:NO dx:1 dy:-1] toResultPoint];
    pointB = [[self firstDifferent:[[ZXAztecPoint alloc] initWithX:cx + 7 y:cy + 7]  color:NO dx:1 dy:1] toResultPoint];
    pointC = [[self firstDifferent:[[ZXAztecPoint alloc] initWithX:cx - 7 y:cy + 7]  color:NO dx:-1 dy:1] toResultPoint];
    pointD = [[self firstDifferent:[[ZXAztecPoint alloc] initWithX:cx - 7 y:cy - 7] color:NO dx:-1 dy:-1] toResultPoint];
  } else if (detectorError) {
    if (error) *error = detectorError;
    return nil;
  } else {
    pointA = cornerPoints[0];
    pointB = cornerPoints[1];
    pointC = cornerPoints[2];
    pointD = cornerPoints[3];
  }

  cx = [ZXMathUtils round:([pointA x] + [pointD x] + [pointB x] + [pointC x]) / 4];
  cy = [ZXMathUtils round:([pointA y] + [pointD y] + [pointB y] + [pointC y]) / 4];

  return [[ZXAztecPoint alloc] initWithX:cx y:cy];
}

/**
 * Samples an Aztec matrix from an image
 */
- (ZXBitMatrix *)sampleGrid:(ZXBitMatrix *)anImage
                    topLeft:(ZXResultPoint *)topLeft
                   topRight:(ZXResultPoint *)topRight
                bottomRight:(ZXResultPoint *)bottomRight
                 bottomLeft:(ZXResultPoint *)bottomLeft
                      error:(NSError **)error {
  ZXGridSampler *sampler = [ZXGridSampler instance];
  int dimension = [self dimension];

  float low = dimension/2.0f - self.nbCenterLayers;
  float high = dimension/2.0f + self.nbCenterLayers;

  return [sampler sampleGrid:anImage
                  dimensionX:dimension
                  dimensionY:dimension
                       p1ToX:low p1ToY:low   // topleft
                       p2ToX:high p2ToY:low  // topright
                       p3ToX:high p3ToY:high // bottomright
                       p4ToX:low p4ToY:high  // bottomleft
                     p1FromX:topLeft.x p1FromY:topLeft.y
                     p2FromX:topRight.x p2FromY:topRight.y
                     p3FromX:bottomRight.x p3FromY:bottomRight.y
                     p4FromX:bottomLeft.x p4FromY:bottomLeft.y
                       error:error];
}

/**
 * Sets number of layers and number of data blocks from parameter bits
 */
- (void)parameters:(NSArray *)parameterData {
  int nbBitsForNbLayers;
  int nbBitsForNbDatablocks;

  if (self.compact) {
    nbBitsForNbLayers = 2;
    nbBitsForNbDatablocks = 6;
  } else {
    nbBitsForNbLayers = 5;
    nbBitsForNbDatablocks = 11;
  }

  for (int i = 0; i < nbBitsForNbLayers; i++) {
    self.nbLayers <<= 1;
    if ([parameterData[i] boolValue]) {
      self.nbLayers++;
    }
  }

  for (int i = nbBitsForNbLayers; i < nbBitsForNbLayers + nbBitsForNbDatablocks; i++) {
    self.nbDataBlocks <<= 1;
    if ([parameterData[i] boolValue]) {
      self.nbDataBlocks++;
    }
  }

  self.nbLayers++;
  self.nbDataBlocks++;
}

/**
 * Samples a line
 */
- (NSArray *)sampleLine:(ZXResultPoint *)p1 p2:(ZXResultPoint *)p2 size:(int)size {
  NSMutableArray *res = [NSMutableArray arrayWithCapacity:size];
  float d = [self resultDistance:p1 b:p2];
  float moduleSize = d / (size - 1);
  float dx = moduleSize * (p2.x - p1.x) / d;
  float dy = moduleSize * (p2.y - p1.y) / d;

  float px = p1.x;
  float py = p1.y;

  for (int i = 0; i < size; i++) {
    [res addObject:@([self.image getX:[ZXMathUtils round:px] y:[ZXMathUtils round:py]])];
    px += dx;
    py += dy;
  }

  return res;
}


/**
 * return true if the border of the rectangle passed in parameter is compound of white points only
 * or black points only
 */
- (BOOL)isWhiteOrBlackRectangle:(ZXAztecPoint *)p1 p2:(ZXAztecPoint *)p2 p3:(ZXAztecPoint *)p3 p4:(ZXAztecPoint *)p4 {
  int corr = 3;

  p1 = [[ZXAztecPoint alloc] initWithX:p1.x - corr y:p1.y + corr];
  p2 = [[ZXAztecPoint alloc] initWithX:p2.x - corr y:p2.y - corr];
  p3 = [[ZXAztecPoint alloc] initWithX:p3.x + corr y:p3.y - corr];
  p4 = [[ZXAztecPoint alloc] initWithX:p4.x + corr y:p4.y + corr];

  int cInit = [self color:p4 p2:p1];

  if (cInit == 0) {
    return NO;
  }

  int c = [self color:p1 p2:p2];

  if (c != cInit) {
    return NO;
  }

  c = [self color:p2 p2:p3];

  if (c != cInit) {
    return NO;
  }

  c = [self color:p3 p2:p4];

  return c == cInit;
}

/**
 * Gets the color of a segment
 * return 1 if segment more than 90% black, -1 if segment is more than 90% white, 0 else
 */
- (int)color:(ZXAztecPoint *)p1 p2:(ZXAztecPoint *)p2 {
  float d = [self distance:p1 b:p2];
  float dx = (p2.x - p1.x) / d;
  float dy = (p2.y - p1.y) / d;
  int error = 0;

  float px = p1.x;
  float py = p1.y;

  BOOL colorModel = [self.image getX:p1.x y:p1.y];

  for (int i = 0; i < d; i++) {
    px += dx;
    py += dy;
    if ([self.image getX:[ZXMathUtils round:px] y:[ZXMathUtils round:py]] != colorModel) {
      error++;
    }
  }

  float errRatio = (float)error / d;

  if (errRatio > 0.1f && errRatio < 0.9f) {
    return 0;
  }

  return (errRatio <= 0.1f) == colorModel ? 1 : -1;
}

/**
 * Gets the coordinate of the first point with a different color in the given direction
 */
- (ZXAztecPoint *)firstDifferent:(ZXAztecPoint *)init color:(BOOL)color dx:(int)dx dy:(int)dy {
  int x = init.x + dx;
  int y = init.y + dy;

  while ([self isValidX:x y:y] && [self.image getX:x y:y] == color) {
    x += dx;
    y += dy;
  }

  x -= dx;
  y -= dy;

  while ([self isValidX:x y:y] && [self.image getX:x y:y] == color) {
    x += dx;
  }
  x -= dx;

  while ([self isValidX:x y:y] && [self.image getX:x y:y] == color) {
    y += dy;
  }
  y -= dy;

  return [[ZXAztecPoint alloc] initWithX:x y:y];
}

/**
 * Expand the square represented by the corner points by pushing out equally in all directions
 */
- (NSArray *)expandSquare:(NSArray *)cornerPoints oldSide:(float)oldSide newSide:(float)newSide {
  ZXResultPoint *cornerPoints0 = (ZXResultPoint *)cornerPoints[0];
  ZXResultPoint *cornerPoints1 = (ZXResultPoint *)cornerPoints[1];
  ZXResultPoint *cornerPoints2 = (ZXResultPoint *)cornerPoints[2];
  ZXResultPoint *cornerPoints3 = (ZXResultPoint *)cornerPoints[3];

  float ratio = newSide / (2 * oldSide);
  float dx =  cornerPoints0.x - cornerPoints2.x;
  float dy = cornerPoints0.y - cornerPoints2.y;
  float centerx = (cornerPoints0.x + cornerPoints2.x) / 2.0f;
  float centery = (cornerPoints0.y + cornerPoints2.y) / 2.0f;

  ZXResultPoint *result0 = [[ZXResultPoint alloc] initWithX:centerx + ratio * dx y:centery + ratio * dy];
  ZXResultPoint *result2 = [[ZXResultPoint alloc] initWithX:centerx - ratio * dx y:centery - ratio * dy];

  dx = cornerPoints1.x - cornerPoints3.x;
  dy = cornerPoints1.y - cornerPoints3.y;
  centerx = (cornerPoints1.x + cornerPoints3.x) / 2.0f;
  centery = (cornerPoints1.y + cornerPoints3.y) / 2.0f;
  ZXResultPoint *result1 = [[ZXResultPoint alloc] initWithX:centerx + ratio * dx y:centery + ratio * dy];
  ZXResultPoint *result3 = [[ZXResultPoint alloc] initWithX:centerx - ratio * dx y:centery - ratio * dy];

  return @[result0, result1, result2, result3];
}

- (BOOL)isValidX:(int)x y:(int)y {
  return x >= 0 && x < self.image.width && y > 0 && y < self.image.height;
}

- (BOOL)isValid:(ZXResultPoint *)point {
  int x = [ZXMathUtils round:point.x];
  int y = [ZXMathUtils round:point.y];
  return [self isValidX:x y:y];
}

- (float)distance:(ZXAztecPoint *)a b:(ZXAztecPoint *)b {
  return [ZXMathUtils distance:a.x aY:a.y bX:b.x bY:b.y];
}

- (float)resultDistance:(ZXResultPoint *)a b:(ZXResultPoint *)b {
  return [ZXMathUtils distance:a.x aY:a.y bX:b.x bY:b.y];
}

- (int)dimension {
  if (self.compact) {
    return 4 * self.nbLayers + 11;
  }
  if (self.nbLayers <= 4) {
    return 4 * self.nbLayers + 15;
  }
  return 4 * self.nbLayers + 2 * ((self.nbLayers-4)/8 + 1) + 15;
}

@end

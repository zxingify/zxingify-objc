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

#import "ZXDataMatrixDetector.h"
#import "ZXDetectorResult.h"
#import "ZXErrors.h"
#import "ZXGridSampler.h"
#import "ZXMathUtils.h"
#import "ZXResultPoint.h"
#import "ZXWhiteRectangleDetector.h"


@interface ZXDataMatrixDetector ()

@property (nonatomic, strong, readonly) ZXBitMatrix *image;
@property (nonatomic, strong, readonly) ZXWhiteRectangleDetector *rectangleDetector;

@end

@implementation ZXDataMatrixDetector

- (id)initWithImage:(ZXBitMatrix *)image error:(NSError **)error {
  if (self = [super init]) {
    _image = image;
    _rectangleDetector = [[ZXWhiteRectangleDetector alloc] initWithImage:_image error:error];
    if (!_rectangleDetector) {
      return nil;
    }
  }

  return self;
}

- (ZXDetectorResult *)detectWithError:(NSError **)error {
  NSArray *cornerPoints = [self.rectangleDetector detectWithError:error];
  if (!cornerPoints) {
    return nil;
  }

  NSMutableArray *points = [self detectSolid1:[cornerPoints mutableCopy]];
  points = [self detectSolid2:points];
  points[3] = [self correctTopRight:points];
  if (!points[3]) {
    return nil;
  }
  points = [self shiftToModuleCenter:points];

  ZXResultPoint *topLeft = points[0];
  ZXResultPoint *bottomLeft = points[1];
  ZXResultPoint *bottomRight = points[2];
  ZXResultPoint *topRight = points[3];

  int dimensionTop = [self transitionsBetween:topLeft to:topRight] + 1;
  int dimensionRight = [self transitionsBetween:bottomRight to:topRight] + 1;

  if ((dimensionTop & 0x01) == 1) {
    dimensionTop += 1;
  }
  if ((dimensionRight & 0x01) == 1) {
    dimensionRight += 1;
  }

  if (4 * dimensionTop < 7 * dimensionRight && 4 * dimensionRight < 7 * dimensionTop) {
    // The matrix is square
    dimensionTop = dimensionRight = MAX(dimensionTop, dimensionRight);
  }

  ZXBitMatrix *bits = [self sampleGrid:self.image topLeft:topLeft bottomLeft:bottomLeft bottomRight:bottomRight topRight:topRight dimensionX:dimensionTop dimensionY:dimensionRight error:error];

  return [[ZXDetectorResult alloc] initWithBits:bits points:@[topLeft, bottomLeft, bottomRight, topRight]];

  /*
  NSMutableArray *transitions = [NSMutableArray arrayWithCapacity:4];
  [transitions addObject:[self transitionsBetween:pointA to:pointB]];
  [transitions addObject:[self transitionsBetween:pointA to:pointC]];
  [transitions addObject:[self transitionsBetween:pointB to:pointD]];
  [transitions addObject:[self transitionsBetween:pointC to:pointD]];
  [transitions sortUsingSelector:@selector(compare:)];

  ZXResultPointsAndTransitions *lSideOne = (ZXResultPointsAndTransitions *)transitions[0];
  ZXResultPointsAndTransitions *lSideTwo = (ZXResultPointsAndTransitions *)transitions[1];

  NSMutableDictionary *pointCount = [NSMutableDictionary dictionary];
  [self increment:pointCount key:[lSideOne from]];
  [self increment:pointCount key:[lSideOne to]];
  [self increment:pointCount key:[lSideTwo from]];
  [self increment:pointCount key:[lSideTwo to]];

  ZXResultPoint *maybeTopLeft = nil;
  ZXResultPoint *bottomLeft = nil;
  ZXResultPoint *maybeBottomRight = nil;
  for (ZXResultPoint *point in [pointCount allKeys]) {
    NSNumber *value = pointCount[point];
    if ([value intValue] == 2) {
      bottomLeft = point;
    } else {
      if (maybeTopLeft == nil) {
        maybeTopLeft = point;
      } else {
        maybeBottomRight = point;
      }
    }
  }

  if (maybeTopLeft == nil || bottomLeft == nil || maybeBottomRight == nil) {
    if (error) *error = ZXNotFoundErrorInstance();
    return nil;
  }

  NSMutableArray *corners = [NSMutableArray arrayWithObjects:maybeTopLeft, bottomLeft, maybeBottomRight, nil];
  [ZXResultPoint orderBestPatterns:corners];

  ZXResultPoint *bottomRight = corners[0];
  bottomLeft = corners[1];
  ZXResultPoint *topLeft = corners[2];

  ZXResultPoint *topRight;
  if (!pointCount[pointA]) {
    topRight = pointA;
  } else if (!pointCount[pointB]) {
    topRight = pointB;
  } else if (!pointCount[pointC]) {
    topRight = pointC;
  } else {
    topRight = pointD;
  }

  ZXBitMatrix *bits;
  ZXResultPoint *correctedTopRight;

  if (4 * dimensionTop >= 7 * dimensionRight || 4 * dimensionRight >= 7 * dimensionTop) {
    correctedTopRight = [self correctTopRightRectangular:bottomLeft bottomRight:bottomRight topLeft:topLeft topRight:topRight dimensionTop:dimensionTop dimensionRight:dimensionRight];
    if (correctedTopRight == nil) {
      correctedTopRight = topRight;
    }

    dimensionTop = [[self transitionsBetween:topLeft to:correctedTopRight] transitions];
    dimensionRight = [[self transitionsBetween:bottomRight to:correctedTopRight] transitions];

    if ((dimensionTop & 0x01) == 1) {
      dimensionTop++;
    }

    if ((dimensionRight & 0x01) == 1) {
      dimensionRight++;
    }

    bits = [self sampleGrid:self.image topLeft:topLeft bottomLeft:bottomLeft bottomRight:bottomRight topRight:correctedTopRight dimensionX:dimensionTop dimensionY:dimensionRight error:error];
    if (!bits) {
      return nil;
    }
  } else {
    int dimension = MIN(dimensionRight, dimensionTop);
    correctedTopRight = [self correctTopRight:bottomLeft bottomRight:bottomRight topLeft:topLeft topRight:topRight dimension:dimension];
    if (correctedTopRight == nil) {
      correctedTopRight = topRight;
    }

    int dimensionCorrected = MAX([[self transitionsBetween:topLeft to:correctedTopRight] transitions], [[self transitionsBetween:bottomRight to:correctedTopRight] transitions]);
    dimensionCorrected++;
    if ((dimensionCorrected & 0x01) == 1) {
      dimensionCorrected++;
    }

    bits = [self sampleGrid:self.image topLeft:topLeft bottomLeft:bottomLeft bottomRight:bottomRight topRight:correctedTopRight dimensionX:dimensionCorrected dimensionY:dimensionCorrected error:error];
    if (!bits) {
      return nil;
    }
  }
  */
}

- (ZXResultPoint *)shiftPoint:(ZXResultPoint *)point to:(ZXResultPoint *)to div:(int)div {
  float x = (to.x - point.x) / (div + 1);
  float y = (to.y - point.y) / (div + 1);
  return [[ZXResultPoint alloc] initWithX:point.x + x y:point.y + y];
}

- (ZXResultPoint *)moveAway:(ZXResultPoint *)point fromX:(float)fromX fromY:(float)fromY {
  float x = point.x;
  float y = point.y;

  if (x < fromX) {
    x -= 1;
  } else {
    x += 1;
  }

  if (y < fromY) {
    y -= 1;
  } else {
    y += 1;
  }

  return [[ZXResultPoint alloc] initWithX:x y:y];
}

- (NSMutableArray *)detectSolid1:(NSMutableArray *)cornerPoints {
  return nil;
}

- (NSMutableArray *)detectSolid2:(NSMutableArray *)points {
  return nil;
}

/**
 * Calculates the corner position of the white top right module.
 */
- (ZXResultPoint *)correctTopRight:(NSMutableArray *)points {
  // A..D
  // |  :
  // B--C
  ZXResultPoint *pointA = points[0];
  ZXResultPoint *pointB = points[1];
  ZXResultPoint *pointC = points[2];
  ZXResultPoint *pointD = points[3];

  // shift points for safe transition detection.
  int trTop = [self transitionsBetween:pointA to:pointD];
  int trRight = [self transitionsBetween:pointB to:pointD];
  ZXResultPoint *pointAs = [self shiftPoint:pointA to:pointB div:(trRight + 1) * 4];
  ZXResultPoint *pointCs = [self shiftPoint:pointC to:pointB div:(trTop + 1) * 4];

  trTop = [self transitionsBetween:pointAs to:pointD];
  trRight = [self transitionsBetween:pointCs to:pointD];

  ZXResultPoint *candidate1 = [[ZXResultPoint alloc] initWithX:pointD.x + (pointC.x - pointB.x) / (trTop + 1)
                                                             y:pointD.y + (pointC.y - pointB.y) / (trTop + 1)];

  ZXResultPoint *candidate2 = [[ZXResultPoint alloc] initWithX:pointD.x + (pointA.x - pointB.x) / (trRight + 1)
                                                             y:pointD.y + (pointA.y - pointB.y) / (trRight + 1)];

  if (![self isValid:candidate1]) {
    if ([self isValid:candidate2]) {
      return candidate2;
    }
    return nil;
  }
  if (![self isValid:candidate2]) {
    return candidate1;
  }

  int sumc1 = [self transitionsBetween:pointAs to:candidate1] + [self transitionsBetween:pointCs to:candidate1];
  int sumc2 = [self transitionsBetween:pointAs to:candidate2] + [self transitionsBetween:pointCs to:candidate2];

  if (sumc1 > sumc2) {
    return candidate1;
  } else {
    return candidate2;
  }
}

- (BOOL) isValid:(ZXResultPoint *)p {
  return [p x] >= 0 && [p x] < self.image.width && [p y] > 0 && [p y] < self.image.height;
}

- (NSMutableArray *)shiftToModuleCenter:(NSMutableArray *)points {
  return nil;
}

- (ZXBitMatrix *)sampleGrid:(ZXBitMatrix *)image
                    topLeft:(ZXResultPoint *)topLeft
                 bottomLeft:(ZXResultPoint *)bottomLeft
                bottomRight:(ZXResultPoint *)bottomRight
                   topRight:(ZXResultPoint *)topRight
                 dimensionX:(int)dimensionX
                 dimensionY:(int)dimensionY
                      error:(NSError **)error {
  ZXGridSampler *sampler = [ZXGridSampler instance];
  return [sampler sampleGrid:image
                  dimensionX:dimensionX dimensionY:dimensionY
                       p1ToX:0.5f p1ToY:0.5f
                       p2ToX:dimensionX - 0.5f p2ToY:0.5f
                       p3ToX:dimensionX - 0.5f p3ToY:dimensionY - 0.5f
                       p4ToX:0.5f p4ToY:dimensionY - 0.5f
                     p1FromX:[topLeft x] p1FromY:[topLeft y]
                     p2FromX:[topRight x] p2FromY:[topRight y]
                     p3FromX:[bottomRight x] p3FromY:[bottomRight y]
                     p4FromX:[bottomLeft x] p4FromY:[bottomLeft y]
                       error:error];
}

/**
 * Counts the number of black/white transitions between two points, using something like Bresenham's algorithm.
 */
- (int)transitionsBetween:(ZXResultPoint *)from to:(ZXResultPoint *)to {
  int fromX = (int)[from x];
  int fromY = (int)[from y];
  int toX = (int)[to x];
  int toY = (int)[to y];
  BOOL steep = abs(toY - fromY) > abs(toX - fromX);
  if (steep) {
    int temp = fromX;
    fromX = fromY;
    fromY = temp;
    temp = toX;
    toX = toY;
    toY = temp;
  }

  int dx = abs(toX - fromX);
  int dy = abs(toY - fromY);
  int error = -dx / 2;
  int ystep = fromY < toY ? 1 : -1;
  int xstep = fromX < toX ? 1 : -1;
  int transitions = 0;
  BOOL inBlack = [self.image getX:steep ? fromY : fromX y:steep ? fromX : fromY];
  for (int x = fromX, y = fromY; x != toX; x += xstep) {
    BOOL isBlack = [self.image getX:steep ? y : x y:steep ? x : y];
    if (isBlack != inBlack) {
      transitions++;
      inBlack = isBlack;
    }
    error += dy;
    if (error > 0) {
      if (y == toY) {
        break;
      }
      y += ystep;
      error -= dx;
    }
  }
  return transitions;
}

@end

#import "DefaultGridSampler.h"

@implementation DefaultGridSampler

- (BitMatrix *) sampleGrid:(BitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY p1ToX:(float)p1ToX p1ToY:(float)p1ToY p2ToX:(float)p2ToX p2ToY:(float)p2ToY p3ToX:(float)p3ToX p3ToY:(float)p3ToY p4ToX:(float)p4ToX p4ToY:(float)p4ToY p1FromX:(float)p1FromX p1FromY:(float)p1FromY p2FromX:(float)p2FromX p2FromY:(float)p2FromY p3FromX:(float)p3FromX p3FromY:(float)p3FromY p4FromX:(float)p4FromX p4FromY:(float)p4FromY {
  PerspectiveTransform * transform = [PerspectiveTransform quadrilateralToQuadrilateral:p1ToX param1:p1ToY param2:p2ToX param3:p2ToY param4:p3ToX param5:p3ToY param6:p4ToX param7:p4ToY param8:p1FromX param9:p1FromY param10:p2FromX param11:p2FromY param12:p3FromX param13:p3FromY param14:p4FromX param15:p4FromY];
  return [self sampleGrid:image dimensionX:dimensionX dimensionY:dimensionY transform:transform];
}

- (BitMatrix *) sampleGrid:(BitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY transform:(PerspectiveTransform *)transform {
  if (dimensionX <= 0 || dimensionY <= 0) {
    @throw [NotFoundException notFoundInstance];
  }
  BitMatrix * bits = [[[BitMatrix alloc] init:dimensionX param1:dimensionY] autorelease];
  NSArray * points = [NSArray array];

  for (int y = 0; y < dimensionY; y++) {
    int max = points.length;
    float iValue = (float)y + 0.5f;

    for (int x = 0; x < max; x += 2) {
      points[x] = (float)(x >> 1) + 0.5f;
      points[x + 1] = iValue;
    }

    [transform transformPoints:points];
    [self checkAndNudgePoints:image param1:points];

    @try {

      for (int x = 0; x < max; x += 2) {
        if ([image get:(int)points[x] param1:(int)points[x + 1]]) {
          [bits set:x >> 1 param1:y];
        }
      }

    }
    @catch (ArrayIndexOutOfBoundsException * aioobe) {
      @throw [NotFoundException notFoundInstance];
    }
  }

  return bits;
}

@end

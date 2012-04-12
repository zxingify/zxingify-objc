#import "ZXBitMatrix.h"
#import "ZXDefaultGridSampler.h"
#import "ZXNotFoundException.h"
#import "ZXPerspectiveTransform.h"

@implementation ZXDefaultGridSampler

- (ZXBitMatrix *) sampleGrid:(ZXBitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY p1ToX:(float)p1ToX p1ToY:(float)p1ToY p2ToX:(float)p2ToX p2ToY:(float)p2ToY p3ToX:(float)p3ToX p3ToY:(float)p3ToY p4ToX:(float)p4ToX p4ToY:(float)p4ToY p1FromX:(float)p1FromX p1FromY:(float)p1FromY p2FromX:(float)p2FromX p2FromY:(float)p2FromY p3FromX:(float)p3FromX p3FromY:(float)p3FromY p4FromX:(float)p4FromX p4FromY:(float)p4FromY {
  ZXPerspectiveTransform * transform =
    [ZXPerspectiveTransform quadrilateralToQuadrilateral:p1ToX y0:p1ToY
                                                    x1:p2ToX y1:p2ToY
                                                    x2:p3ToX y2:p3ToY
                                                    x3:p4ToX y3:p4ToY
                                                   x0p:p1FromX y0p:p1FromY
                                                   x1p:p2FromX y1p:p2FromY
                                                   x2p:p3FromX y2p:p3FromY
                                                   x3p:p4FromX y3p:p4FromY];
  return [self sampleGrid:image dimensionX:dimensionX dimensionY:dimensionY transform:transform];
}

- (ZXBitMatrix *) sampleGrid:(ZXBitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY transform:(ZXPerspectiveTransform *)transform {
  if (dimensionX <= 0 || dimensionY <= 0) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  ZXBitMatrix * bits = [[[ZXBitMatrix alloc] initWithWidth:dimensionX height:dimensionY] autorelease];
  NSMutableArray * points = [NSMutableArray arrayWithCapacity:dimensionX << 1];

  for (int y = 0; y < dimensionY; y++) {
    int max = dimensionX << 1;
    float iValue = (float)y + 0.5f;
    for (int x = 0; x < max; x += 2) {
      [points addObject:[NSNumber numberWithFloat:(float)(x >> 1) + 0.5f]];
      [points addObject:[NSNumber numberWithFloat:iValue]];
    }
    [transform transformPoints:points];

    [ZXGridSampler checkAndNudgePoints:image points:points];
    for (int x = 0; x < max; x += 2) {
      if ([image get:[[points objectAtIndex:x] intValue] y:[[points objectAtIndex:x + 1] intValue]]) {
        [bits set:x >> 1 y:y];
      }
    }
  }

  return bits;
}

@end

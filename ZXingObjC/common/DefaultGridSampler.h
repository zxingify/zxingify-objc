#import "NotFoundException.h"

/**
 * @author Sean Owen
 */

@interface DefaultGridSampler : GridSampler {
}

- (BitMatrix *) sampleGrid:(BitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY p1ToX:(float)p1ToX p1ToY:(float)p1ToY p2ToX:(float)p2ToX p2ToY:(float)p2ToY p3ToX:(float)p3ToX p3ToY:(float)p3ToY p4ToX:(float)p4ToX p4ToY:(float)p4ToY p1FromX:(float)p1FromX p1FromY:(float)p1FromY p2FromX:(float)p2FromX p2FromY:(float)p2FromY p3FromX:(float)p3FromX p3FromY:(float)p3FromY p4FromX:(float)p4FromX p4FromY:(float)p4FromY;
- (BitMatrix *) sampleGrid:(BitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY transform:(PerspectiveTransform *)transform;
@end

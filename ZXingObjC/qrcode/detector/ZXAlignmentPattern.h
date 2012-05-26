#import "ZXResultPoint.h"

/**
 * Encapsulates an alignment pattern, which are the smaller square patterns found in
 * all but the simplest QR Codes.
 */

@interface ZXAlignmentPattern : ZXResultPoint

- (id)initWithPosX:(float)posX posY:(float)posY estimatedModuleSize:(float)estimatedModuleSize;
- (BOOL)aboutEquals:(float)moduleSize i:(float)i j:(float)j;
- (ZXAlignmentPattern*)combineEstimateI:(float)i j:(float)j newModuleSize:(float)newModuleSize;

@end

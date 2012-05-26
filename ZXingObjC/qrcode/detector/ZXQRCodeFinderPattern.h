#import "ZXResultPoint.h"

/**
 * Encapsulates a finder pattern, which are the three square patterns found in
 * the corners of QR Codes. It also encapsulates a count of similar finder patterns,
 * as a convenience to the finder's bookkeeping.
 */

@interface ZXQRCodeFinderPattern : ZXResultPoint

@property (nonatomic, assign, readonly) int count;
@property (nonatomic, assign, readonly) float estimatedModuleSize;

- (id)initWithPosX:(float)posX posY:(float)posY estimatedModuleSize:(float)estimatedModuleSize;
- (id)initWithPosX:(float)posX posY:(float)posY estimatedModuleSize:(float)estimatedModuleSize count:(int)count;
- (void)incrementCount;
- (BOOL)aboutEquals:(float)moduleSize i:(float)i j:(float)j;
- (ZXQRCodeFinderPattern*)combineEstimateI:(float)i j:(float)j newModuleSize:(float)newModuleSize;

@end

#import "ResultPoint.h"

/**
 * <p>Encapsulates a finder pattern, which are the three square patterns found in
 * the corners of QR Codes. It also encapsulates a count of similar finder patterns,
 * as a convenience to the finder's bookkeeping.</p>
 * 
 * @author Sean Owen
 */

@interface FinderPattern : ResultPoint {
  float estimatedModuleSize;
  int count;
}

@property(nonatomic, readonly) float estimatedModuleSize;
- (id) init:(float)posX posY:(float)posY estimatedModuleSize:(float)estimatedModuleSize;
- (int) getCount;
- (void) incrementCount;
- (BOOL) aboutEquals:(float)moduleSize i:(float)i j:(float)j;
@end

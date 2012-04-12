#import "ZXResultPoint.h"

/**
 * <p>Encapsulates an alignment pattern, which are the smaller square patterns found in
 * all but the simplest QR Codes.</p>
 * 
 * @author Sean Owen
 */

@interface ZXAlignmentPattern : ZXResultPoint {
  float estimatedModuleSize;
}

- (id) initWithPosX:(float)posX posY:(float)posY estimatedModuleSize:(float)estimatedModuleSize;
- (BOOL) aboutEquals:(float)moduleSize i:(float)i j:(float)j;

@end

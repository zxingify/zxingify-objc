#import "ZXResultPoint.h"
#import "ZXBitMatrix.h"

/**
 * Detects a candidate barcode-like rectangular region within an image. It
 * starts around the center of the image, increases the size of the candidate
 * region until it finds a white rectangular region. By keeping track of the
 * last black points it encountered, it determines the corners of the barcode.
 */

@interface ZXWhiteRectangleDetector : NSObject 

- (id)initWithImage:(ZXBitMatrix *)image;
- (id)initWithImage:(ZXBitMatrix *)image initSize:(int)initSize x:(int)x y:(int)y;
- (NSArray *)detect;

@end

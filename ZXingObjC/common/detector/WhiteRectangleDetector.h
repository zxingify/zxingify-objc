#import "ResultPoint.h"
#import "BitMatrix.h"

/**
 * <p>
 * Detects a candidate barcode-like rectangular region within an image. It
 * starts around the center of the image, increases the size of the candidate
 * region until it finds a white rectangular region. By keeping track of the
 * last black points it encountered, it determines the corners of the barcode.
 * </p>
 * 
 * @author David Olivier
 */

@interface WhiteRectangleDetector : NSObject 

- (id) initWithImage:(BitMatrix *)image;
- (id) initWithImage:(BitMatrix *)image initSize:(int)initSize x:(int)x y:(int)y;
- (NSArray *) detect;

@end

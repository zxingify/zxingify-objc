#import "Binarizer.h"
#import "BitArray.h"
#import "BitMatrix.h"

/**
 * This class is the core bitmap class used by ZXing to represent 1 bit data. Reader objects
 * accept a BinaryBitmap and attempt to decode it.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface BinaryBitmap : NSObject {
  BitMatrix * matrix;
}

@property(nonatomic, readonly) int width;
@property(nonatomic, readonly) int height;
@property(nonatomic, retain, readonly) BitMatrix * blackMatrix;
@property(nonatomic, readonly) BOOL cropSupported;
@property(nonatomic, readonly) BOOL rotateSupported;
- (id) initWithBinarizer:(Binarizer *)binarizer;
- (BitArray *) getBlackRow:(int)y row:(BitArray *)row;
- (BinaryBitmap *) crop:(int)left top:(int)top width:(int)width height:(int)height;
- (BinaryBitmap *) rotateCounterClockwise;
@end

#import "ZXBinarizer.h"
#import "ZXBitArray.h"
#import "ZXBitMatrix.h"

/**
 * This class is the core bitmap class used by ZXing to represent 1 bit data. Reader objects
 * accept a BinaryBitmap and attempt to decode it.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface ZXBinaryBitmap : NSObject {
  ZXBitMatrix * matrix;
}

@property(nonatomic, readonly) int width;
@property(nonatomic, readonly) int height;
@property(nonatomic, retain, readonly) ZXBitMatrix * blackMatrix;
@property(nonatomic, readonly) BOOL cropSupported;
@property(nonatomic, readonly) BOOL rotateSupported;
- (id) initWithBinarizer:(ZXBinarizer *)binarizer;
- (ZXBitArray *) getBlackRow:(int)y row:(ZXBitArray *)row;
- (ZXBinaryBitmap *) crop:(int)left top:(int)top width:(int)width height:(int)height;
- (ZXBinaryBitmap *) rotateCounterClockwise;

@end

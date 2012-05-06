/**
 * This class is the core bitmap class used by ZXing to represent 1 bit data. Reader objects
 * accept a BinaryBitmap and attempt to decode it.
 */

@class ZXBinarizer, ZXBitArray, ZXBitMatrix;

@interface ZXBinaryBitmap : NSObject

@property(nonatomic, readonly) int width;
@property(nonatomic, readonly) int height;
@property(nonatomic, readonly) BOOL cropSupported;
@property(nonatomic, readonly) BOOL rotateSupported;

- (id)initWithBinarizer:(ZXBinarizer *)binarizer;
- (ZXBitArray *)blackRow:(int)y row:(ZXBitArray *)row;
- (ZXBitMatrix *)blackMatrix;
- (ZXBinaryBitmap *)crop:(int)left top:(int)top width:(int)width height:(int)height;
- (ZXBinaryBitmap *)rotateCounterClockwise;

@end

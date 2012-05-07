#import "ZXBitArray.h"
#import "ZXBitMatrix.h"
#import "ZXLuminanceSource.h"

/**
 * This class hierarchy provides a set of methods to convert luminance data to 1 bit data.
 * It allows the algorithm to vary polymorphically, for example allowing a very expensive
 * thresholding technique for servers and a fast one for mobile. It also permits the implementation
 * to vary, e.g. a JNI version for Android and a Java fallback version for other platforms.
 */

@interface ZXBinarizer : NSObject

@property (nonatomic, retain, readonly) ZXLuminanceSource* luminanceSource;

- (id)initWithSource:(ZXLuminanceSource *)source;
- (ZXBitMatrix *)blackMatrix;
- (ZXBitArray *)blackRow:(int)y row:(ZXBitArray *)row;
- (ZXBinarizer *)createBinarizer:(ZXLuminanceSource *)source;
- (CGImageRef)createImage;

@end

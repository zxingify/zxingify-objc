#import "BitArray.h"
#import "BitMatrix.h"
#import "LuminanceSource.h"

/**
 * This class hierarchy provides a set of methods to convert luminance data to 1 bit data.
 * It allows the algorithm to vary polymorphically, for example allowing a very expensive
 * thresholding technique for servers and a fast one for mobile. It also permits the implementation
 * to vary, e.g. a JNI version for Android and a Java fallback version for other platforms.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface Binarizer : NSObject

@property(nonatomic, retain) LuminanceSource * luminanceSource;
@property(nonatomic, retain) BitMatrix * blackMatrix;
- (id) initWithSource:(LuminanceSource *)source;
- (BitArray *) getBlackRow:(int)y row:(BitArray *)row;
- (Binarizer *) createBinarizer:(LuminanceSource *)source;

@end

#import "BitMatrix.h"
#import "ResultPoint.h"

/**
 * <p>Encapsulates the result of detecting a barcode in an image. This includes the raw
 * matrix of black/white pixels corresponding to the barcode, and possibly points of interest
 * in the image, like the location of finder patterns or corners of the barcode in the image.</p>
 * 
 * @author Sean Owen
 */

@interface DetectorResult : NSObject {
  BitMatrix * bits;
  NSArray * points;
}

@property(nonatomic, retain, readonly) BitMatrix * bits;
@property(nonatomic, retain, readonly) NSArray * points;
- (id) initWithBits:(BitMatrix *)bits points:(NSArray *)points;

@end

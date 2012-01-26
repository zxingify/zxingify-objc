#import "ChecksumException.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "BitMatrix.h"
#import "DecoderResult.h"

/**
 * <p>The main class which implements PDF417 Code decoding -- as
 * opposed to locating and extracting the PDF417 Code from an image.</p>
 * 
 * @author SITA Lab (kevin.osullivan@sita.aero)
 */

@interface Decoder : NSObject {
}

- (id) init;
- (DecoderResult *) decode:(NSArray *)image;
- (DecoderResult *) decode:(BitMatrix *)bits;
@end

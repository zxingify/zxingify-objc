#import "ChecksumException.h"
#import "FormatException.h"
#import "BitMatrix.h"
#import "DecoderResult.h"
#import "GenericGF.h"
#import "ReedSolomonDecoder.h"
#import "ReedSolomonException.h"

/**
 * <p>The main class which implements Data Matrix Code decoding -- as opposed to locating and extracting
 * the Data Matrix Code from an image.</p>
 * 
 * @author bbrown@google.com (Brian Brown)
 */

@interface Decoder : NSObject {
  ReedSolomonDecoder * rsDecoder;
}

- (id) init;
- (DecoderResult *) decode:(NSArray *)image;
- (DecoderResult *) decode:(BitMatrix *)bits;
@end

#import "ChecksumException.h"
#import "FormatException.h"
#import "BitMatrix.h"
#import "DecoderResult.h"
#import "GenericGF.h"
#import "ReedSolomonDecoder.h"
#import "ReedSolomonException.h"

/**
 * <p>The main class which implements QR Code decoding -- as opposed to locating and extracting
 * the QR Code from an image.</p>
 * 
 * @author Sean Owen
 */

@interface QRCodeDecoder : NSObject {
  ReedSolomonDecoder * rsDecoder;
}

- (DecoderResult *) decode:(NSArray *)image;
- (DecoderResult *) decode:(NSArray *)image hints:(NSMutableDictionary *)hints;
- (DecoderResult *) decode:(BitMatrix *)bits;
- (DecoderResult *) decode:(BitMatrix *)bits hints:(NSMutableDictionary *)hints;
@end

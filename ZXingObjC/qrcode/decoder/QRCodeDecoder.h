/**
 * <p>The main class which implements QR Code decoding -- as opposed to locating and extracting
 * the QR Code from an image.</p>
 * 
 * @author Sean Owen
 */

@class BitMatrix, DecoderResult, ReedSolomonDecoder;

@interface QRCodeDecoder : NSObject {
  ReedSolomonDecoder * rsDecoder;
}

- (DecoderResult *) decode:(BOOL **)image;
- (DecoderResult *) decode:(BOOL **)image hints:(NSMutableDictionary *)hints;
- (DecoderResult *) decodeMatrix:(BitMatrix *)bits;
- (DecoderResult *) decodeMatrix:(BitMatrix *)bits hints:(NSMutableDictionary *)hints;

@end

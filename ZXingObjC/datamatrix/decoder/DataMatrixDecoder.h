/**
 * <p>The main class which implements Data Matrix Code decoding -- as opposed to locating and extracting
 * the Data Matrix Code from an image.</p>
 * 
 * @author bbrown@google.com (Brian Brown)
 */

@class BitMatrix, DecoderResult, ReedSolomonDecoder;

@interface DataMatrixDecoder : NSObject {
  ReedSolomonDecoder * rsDecoder;
}

- (DecoderResult *) decode:(BOOL*[])image;
- (DecoderResult *) decodeMatrix:(BitMatrix *)bits;

@end

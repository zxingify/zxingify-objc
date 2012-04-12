/**
 * <p>The main class which implements Data Matrix Code decoding -- as opposed to locating and extracting
 * the Data Matrix Code from an image.</p>
 * 
 * @author bbrown@google.com (Brian Brown)
 */

@class ZXBitMatrix, ZXDecoderResult, ZXReedSolomonDecoder;

@interface ZXDataMatrixDecoder : NSObject {
  ZXReedSolomonDecoder * rsDecoder;
}

- (ZXDecoderResult *) decode:(BOOL*[])image;
- (ZXDecoderResult *) decodeMatrix:(ZXBitMatrix *)bits;

@end

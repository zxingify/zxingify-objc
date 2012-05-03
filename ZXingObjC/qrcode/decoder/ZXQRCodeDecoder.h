/**
 * <p>The main class which implements QR Code decoding -- as opposed to locating and extracting
 * the QR Code from an image.</p>
 * 
 * @author Sean Owen
 */

@class ZXBitMatrix, ZXDecodeHints, ZXDecodeHints, ZXDecoderResult, ZXReedSolomonDecoder;

@interface ZXQRCodeDecoder : NSObject {
  ZXReedSolomonDecoder * rsDecoder;
}

- (ZXDecoderResult *) decode:(BOOL **)image;
- (ZXDecoderResult *) decode:(BOOL **)image hints:(ZXDecodeHints *)hints;
- (ZXDecoderResult *) decodeMatrix:(ZXBitMatrix *)bits;
- (ZXDecoderResult *) decodeMatrix:(ZXBitMatrix *)bits hints:(ZXDecodeHints *)hints;

@end

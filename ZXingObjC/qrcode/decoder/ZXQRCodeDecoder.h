/**
 * <p>The main class which implements QR Code decoding -- as opposed to locating and extracting
 * the QR Code from an image.</p>
 * 
 * @author Sean Owen
 */

@class ZXBitMatrix, ZXDecoderResult, ZXReedSolomonDecoder;

@interface ZXQRCodeDecoder : NSObject {
  ZXReedSolomonDecoder * rsDecoder;
}

- (ZXDecoderResult *) decode:(BOOL **)image;
- (ZXDecoderResult *) decode:(BOOL **)image hints:(NSMutableDictionary *)hints;
- (ZXDecoderResult *) decodeMatrix:(ZXBitMatrix *)bits;
- (ZXDecoderResult *) decodeMatrix:(ZXBitMatrix *)bits hints:(NSMutableDictionary *)hints;

@end

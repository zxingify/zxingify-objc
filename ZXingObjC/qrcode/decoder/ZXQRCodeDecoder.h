/**
 * The main class which implements QR Code decoding -- as opposed to locating and extracting
 * the QR Code from an image.
 */

@class ZXBitMatrix, ZXDecodeHints, ZXDecodeHints, ZXDecoderResult;

@interface ZXQRCodeDecoder : NSObject

- (ZXDecoderResult *) decode:(BOOL **)image length:(unsigned int)length;
- (ZXDecoderResult *) decode:(BOOL **)image length:(unsigned int)length hints:(ZXDecodeHints *)hints;
- (ZXDecoderResult *) decodeMatrix:(ZXBitMatrix *)bits;
- (ZXDecoderResult *) decodeMatrix:(ZXBitMatrix *)bits hints:(ZXDecodeHints *)hints;

@end

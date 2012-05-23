/**
 * The main class which implements QR Code decoding -- as opposed to locating and extracting
 * the QR Code from an image.
 */

@class ZXBitMatrix, ZXDecodeHints, ZXDecodeHints, ZXDecoderResult;

@interface ZXQRCodeDecoder : NSObject

- (ZXDecoderResult *) decode:(BOOL **)image length:(unsigned int)length error:(NSError**)error;
- (ZXDecoderResult *) decode:(BOOL **)image length:(unsigned int)length hints:(ZXDecodeHints *)hints error:(NSError**)error;
- (ZXDecoderResult *) decodeMatrix:(ZXBitMatrix *)bits error:(NSError**)error;
- (ZXDecoderResult *) decodeMatrix:(ZXBitMatrix *)bits hints:(ZXDecodeHints *)hints error:(NSError**)error;

@end

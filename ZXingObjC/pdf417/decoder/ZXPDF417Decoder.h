/**
 * The main class which implements PDF417 Code decoding -- as
 * opposed to locating and extracting the PDF417 Code from an image.
 */

@class ZXBitMatrix, ZXDecoderResult;

@interface ZXPDF417Decoder : NSObject

- (ZXDecoderResult *)decode:(BOOL **)image length:(unsigned int)length error:(NSError**)error;
- (ZXDecoderResult *)decodeMatrix:(ZXBitMatrix *)bits error:(NSError**)error;

@end

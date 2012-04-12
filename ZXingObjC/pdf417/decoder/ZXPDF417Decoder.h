/**
 * <p>The main class which implements PDF417 Code decoding -- as
 * opposed to locating and extracting the PDF417 Code from an image.</p>
 * 
 * @author SITA Lab (kevin.osullivan@sita.aero)
 */

@class ZXBitMatrix, ZXDecoderResult;

@interface ZXPDF417Decoder : NSObject

- (ZXDecoderResult *) decode:(BOOL **)image;
- (ZXDecoderResult *) decodeMatrix:(ZXBitMatrix *)bits;

@end

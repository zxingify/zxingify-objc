/**
 * <p>The main class which implements PDF417 Code decoding -- as
 * opposed to locating and extracting the PDF417 Code from an image.</p>
 * 
 * @author SITA Lab (kevin.osullivan@sita.aero)
 */

@class BitMatrix, DecoderResult;

@interface PDF417Decoder : NSObject

- (DecoderResult *) decode:(BOOL **)image;
- (DecoderResult *) decodeMatrix:(BitMatrix *)bits;

@end

/**
 * <p>This class contains the methods for decoding the PDF417 codewords.</p>
 * 
 * @author SITA Lab (kevin.osullivan@sita.aero)
 */

@class ZXDecoderResult;

@interface ZXPDF417DecodedBitStreamParser : NSObject

+ (ZXDecoderResult *) decode:(NSArray *)codewords;

@end

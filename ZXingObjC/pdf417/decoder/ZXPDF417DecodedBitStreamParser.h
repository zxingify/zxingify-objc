/**
 * This class contains the methods for decoding the PDF417 codewords.
 */

@class ZXDecoderResult;

@interface ZXPDF417DecodedBitStreamParser : NSObject

+ (ZXDecoderResult *)decode:(NSArray *)codewords error:(NSError**)error;

@end

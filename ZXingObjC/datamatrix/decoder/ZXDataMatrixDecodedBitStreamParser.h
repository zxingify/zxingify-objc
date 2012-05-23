/**
 * Data Matrix Codes can encode text as bits in one of several modes, and can use multiple modes
 * in one Data Matrix Code. This class decodes the bits back into text.
 * 
 * See ISO 16022:2006, 5.2.1 - 5.2.9.2
 */

@class ZXDecoderResult;

@interface ZXDataMatrixDecodedBitStreamParser : NSObject

+ (ZXDecoderResult *)decode:(unsigned char *)bytes length:(unsigned int)length error:(NSError**)error;

@end

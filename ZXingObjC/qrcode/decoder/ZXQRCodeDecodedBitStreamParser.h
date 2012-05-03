/**
 * <p>QR Codes can encode text as bits in one of several modes, and can use multiple modes
 * in one QR Code. This class decodes the bits back into text.</p>
 * 
 * <p>See ISO 18004:2006, 6.4.3 - 6.4.7</p>
 * 
 * @author Sean Owen
 */

@class ZXDecodeHints, ZXDecoderResult, ZXErrorCorrectionLevel, ZXQRCodeVersion;

@interface ZXQRCodeDecodedBitStreamParser : NSObject

+ (ZXDecoderResult *) decode:(unsigned char *)bytes length:(unsigned int)length version:(ZXQRCodeVersion *)version ecLevel:(ZXErrorCorrectionLevel *)ecLevel hints:(ZXDecodeHints *)hints;

@end

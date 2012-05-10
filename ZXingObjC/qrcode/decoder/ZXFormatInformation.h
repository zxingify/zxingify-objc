/**
 * Encapsulates a QR Code's format information, including the data mask used and
 * error correction level.
 */

@class ZXErrorCorrectionLevel;

@interface ZXFormatInformation : NSObject

@property (nonatomic, retain, readonly) ZXErrorCorrectionLevel * errorCorrectionLevel;
@property (nonatomic, assign, readonly) char dataMask;

+ (int)numBitsDiffering:(int)a b:(int)b;
+ (ZXFormatInformation *)decodeFormatInformation:(int)maskedFormatInfo1 maskedFormatInfo2:(int)maskedFormatInfo2;

@end

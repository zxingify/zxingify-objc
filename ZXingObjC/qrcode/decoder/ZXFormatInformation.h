/**
 * <p>Encapsulates a QR Code's format information, including the data mask used and
 * error correction level.</p>
 * 
 * @author Sean Owen
 * @see DataMask
 * @see ErrorCorrectionLevel
 */

@class ZXErrorCorrectionLevel;

@interface ZXFormatInformation : NSObject {
  ZXErrorCorrectionLevel * errorCorrectionLevel;
  char dataMask;
}

@property (nonatomic, readonly) ZXErrorCorrectionLevel * errorCorrectionLevel;
@property (nonatomic, readonly) char dataMask;

+ (int) numBitsDiffering:(int)a b:(int)b;
+ (ZXFormatInformation *) decodeFormatInformation:(int)maskedFormatInfo1 maskedFormatInfo2:(int)maskedFormatInfo2;
- (int) hash;
- (BOOL) isEqualTo:(NSObject *)o;

@end

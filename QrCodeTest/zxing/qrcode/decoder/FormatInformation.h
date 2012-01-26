
/**
 * <p>Encapsulates a QR Code's format information, including the data mask used and
 * error correction level.</p>
 * 
 * @author Sean Owen
 * @see DataMask
 * @see ErrorCorrectionLevel
 */

@interface FormatInformation : NSObject {
  ErrorCorrectionLevel * errorCorrectionLevel;
  char dataMask;
}

+ (int) numBitsDiffering:(int)a b:(int)b;
+ (FormatInformation *) decodeFormatInformation:(int)maskedFormatInfo1 maskedFormatInfo2:(int)maskedFormatInfo2;
- (ErrorCorrectionLevel *) getErrorCorrectionLevel;
- (char) getDataMask;
- (int) hash;
- (BOOL) isEqualTo:(NSObject *)o;
@end

/**
 * @author Sean Owen
 */

@class BitMatrix, FormatInformation, QRCodeVersion;

@interface QRCodeBitMatrixParser : NSObject {
  BitMatrix * bitMatrix;
  QRCodeVersion * parsedVersion;
  FormatInformation * parsedFormatInfo;
}

- (id) initWithBitMatrix:(BitMatrix *)bitMatrix;
- (FormatInformation *) readFormatInformation;
- (QRCodeVersion *) readVersion;
- (NSArray *) readCodewords;

@end

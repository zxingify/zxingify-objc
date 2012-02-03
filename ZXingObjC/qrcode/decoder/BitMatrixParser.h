/**
 * @author Sean Owen
 */

@class BitMatrix, FormatInformation, QrCodeVersion;

@interface BitMatrixParser : NSObject {
  BitMatrix * bitMatrix;
  QrCodeVersion * parsedVersion;
  FormatInformation * parsedFormatInfo;
}

- (id) initWithBitMatrix:(BitMatrix *)bitMatrix;
- (FormatInformation *) readFormatInformation;
- (QrCodeVersion *) readVersion;
- (NSArray *) readCodewords;

@end

/**
 * @author Sean Owen
 */

@class BitMatrix, FormatInformation, QRCodeVersion;

@interface BitMatrixParser : NSObject {
  BitMatrix * bitMatrix;
  QRCodeVersion * parsedVersion;
  FormatInformation * parsedFormatInfo;
}

- (id) initWithBitMatrix:(BitMatrix *)bitMatrix;
- (FormatInformation *) readFormatInformation;
- (QRCodeVersion *) readVersion;
- (NSArray *) readCodewords;

@end

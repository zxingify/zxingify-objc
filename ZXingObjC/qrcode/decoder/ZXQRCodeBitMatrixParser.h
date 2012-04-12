/**
 * @author Sean Owen
 */

@class ZXBitMatrix, ZXFormatInformation, ZXQRCodeVersion;

@interface ZXQRCodeBitMatrixParser : NSObject {
  ZXBitMatrix * bitMatrix;
  ZXQRCodeVersion * parsedVersion;
  ZXFormatInformation * parsedFormatInfo;
}

- (id) initWithBitMatrix:(ZXBitMatrix *)bitMatrix;
- (ZXFormatInformation *) readFormatInformation;
- (ZXQRCodeVersion *) readVersion;
- (NSArray *) readCodewords;

@end

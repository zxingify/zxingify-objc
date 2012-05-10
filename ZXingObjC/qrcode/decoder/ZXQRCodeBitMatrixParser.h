@class ZXBitMatrix, ZXFormatInformation, ZXQRCodeVersion;

@interface ZXQRCodeBitMatrixParser : NSObject

- (id)initWithBitMatrix:(ZXBitMatrix *)bitMatrix;
- (ZXFormatInformation *)readFormatInformation;
- (ZXQRCodeVersion *)readVersion;
- (NSArray *)readCodewords;

@end

@class ZXBitMatrix, ZXFormatInformation, ZXQRCodeVersion;

@interface ZXQRCodeBitMatrixParser : NSObject

- (id)initWithBitMatrix:(ZXBitMatrix *)bitMatrix error:(NSError**)error;
- (ZXFormatInformation *)readFormatInformationWithError:(NSError**)error;
- (ZXQRCodeVersion *)readVersionWithError:(NSError**)error;
- (NSArray *)readCodewordsWithError:(NSError**)error;

@end

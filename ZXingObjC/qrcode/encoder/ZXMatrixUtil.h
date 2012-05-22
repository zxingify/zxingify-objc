@class ZXBitArray, ZXByteMatrix, ZXErrorCorrectionLevel;

@interface ZXMatrixUtil : NSObject

+ (void)buildMatrix:(ZXBitArray *)dataBits ecLevel:(ZXErrorCorrectionLevel *)ecLevel version:(int)version maskPattern:(int)maskPattern matrix:(ZXByteMatrix *)matrix;
+ (void)clearMatrix:(ZXByteMatrix *)matrix;
+ (void)embedBasicPatterns:(int)version matrix:(ZXByteMatrix *)matrix;
+ (void)embedTypeInfo:(ZXErrorCorrectionLevel *)ecLevel maskPattern:(int)maskPattern matrix:(ZXByteMatrix *)matrix;
+ (void)maybeEmbedVersionInfo:(int)version matrix:(ZXByteMatrix *)matrix;
+ (void)embedDataBits:(ZXBitArray *)dataBits maskPattern:(int)maskPattern matrix:(ZXByteMatrix *)matrix;
+ (int)findMSBSet:(int)value;
+ (int)calculateBCHCode:(int)value poly:(int)poly;
+ (void)makeTypeInfoBits:(ZXErrorCorrectionLevel *)ecLevel maskPattern:(int)maskPattern bits:(ZXBitArray *)bits;
+ (void)makeVersionInfoBits:(int)version bits:(ZXBitArray *)bits;

@end

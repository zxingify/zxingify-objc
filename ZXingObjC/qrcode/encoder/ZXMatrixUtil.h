@class ZXBitArray, ZXByteMatrix, ZXErrorCorrectionLevel;

@interface ZXMatrixUtil : NSObject

+ (BOOL)buildMatrix:(ZXBitArray *)dataBits ecLevel:(ZXErrorCorrectionLevel *)ecLevel version:(int)version maskPattern:(int)maskPattern matrix:(ZXByteMatrix *)matrix error:(NSError**)error;
+ (void)clearMatrix:(ZXByteMatrix *)matrix;
+ (BOOL)embedBasicPatterns:(int)version matrix:(ZXByteMatrix *)matrix error:(NSError**)error;
+ (BOOL)embedTypeInfo:(ZXErrorCorrectionLevel *)ecLevel maskPattern:(int)maskPattern matrix:(ZXByteMatrix *)matrix error:(NSError**)error;
+ (BOOL)maybeEmbedVersionInfo:(int)version matrix:(ZXByteMatrix *)matrix error:(NSError**)error;
+ (BOOL)embedDataBits:(ZXBitArray *)dataBits maskPattern:(int)maskPattern matrix:(ZXByteMatrix *)matrix error:(NSError**)error;
+ (int)findMSBSet:(int)value;
+ (int)calculateBCHCode:(int)value poly:(int)poly;
+ (BOOL)makeTypeInfoBits:(ZXErrorCorrectionLevel *)ecLevel maskPattern:(int)maskPattern bits:(ZXBitArray *)bits error:(NSError**)error;
+ (BOOL)makeVersionInfoBits:(int)version bits:(ZXBitArray *)bits error:(NSError**)error;

@end

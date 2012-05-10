@class ZXByteMatrix;

@interface ZXMaskUtil : NSObject

+ (int)applyMaskPenaltyRule1:(ZXByteMatrix *)matrix;
+ (int)applyMaskPenaltyRule2:(ZXByteMatrix *)matrix;
+ (int)applyMaskPenaltyRule3:(ZXByteMatrix *)matrix;
+ (int)applyMaskPenaltyRule4:(ZXByteMatrix *)matrix;
+ (BOOL)dataMaskBit:(int)maskPattern x:(int)x y:(int)y;

@end

/**
 * @author satorux@google.com (Satoru Takabayashi) - creator
 * @author dswitkin@google.com (Daniel Switkin) - ported from C++
 */

@class ZXByteMatrix;

@interface ZXMaskUtil : NSObject

+ (int) applyMaskPenaltyRule1:(ZXByteMatrix *)matrix;
+ (int) applyMaskPenaltyRule2:(ZXByteMatrix *)matrix;
+ (int) applyMaskPenaltyRule3:(ZXByteMatrix *)matrix;
+ (int) applyMaskPenaltyRule4:(ZXByteMatrix *)matrix;
+ (BOOL) getDataMaskBit:(int)maskPattern x:(int)x y:(int)y;

@end

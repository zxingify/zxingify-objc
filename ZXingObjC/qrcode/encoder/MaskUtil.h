#import "ByteMatrix.h"

/**
 * @author satorux@google.com (Satoru Takabayashi) - creator
 * @author dswitkin@google.com (Daniel Switkin) - ported from C++
 */

@interface MaskUtil : NSObject {
}

+ (int) applyMaskPenaltyRule1:(ByteMatrix *)matrix;
+ (int) applyMaskPenaltyRule2:(ByteMatrix *)matrix;
+ (int) applyMaskPenaltyRule3:(ByteMatrix *)matrix;
+ (int) applyMaskPenaltyRule4:(ByteMatrix *)matrix;
+ (BOOL) getDataMaskBit:(int)maskPattern x:(int)x y:(int)y;
@end

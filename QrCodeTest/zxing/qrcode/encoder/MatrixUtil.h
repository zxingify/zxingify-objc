#import "WriterException.h"
#import "BitArray.h"
#import "ErrorCorrectionLevel.h"

/**
 * @author satorux@google.com (Satoru Takabayashi) - creator
 * @author dswitkin@google.com (Daniel Switkin) - ported from C++
 */

@interface MatrixUtil : NSObject {
}

+ (void) clearMatrix:(ByteMatrix *)matrix;
+ (void) buildMatrix:(BitArray *)dataBits ecLevel:(ErrorCorrectionLevel *)ecLevel version:(int)version maskPattern:(int)maskPattern matrix:(ByteMatrix *)matrix;
+ (void) embedBasicPatterns:(int)version matrix:(ByteMatrix *)matrix;
+ (void) embedTypeInfo:(ErrorCorrectionLevel *)ecLevel maskPattern:(int)maskPattern matrix:(ByteMatrix *)matrix;
+ (void) maybeEmbedVersionInfo:(int)version matrix:(ByteMatrix *)matrix;
+ (void) embedDataBits:(BitArray *)dataBits maskPattern:(int)maskPattern matrix:(ByteMatrix *)matrix;
+ (int) findMSBSet:(int)value;
+ (int) calculateBCHCode:(int)value poly:(int)poly;
+ (void) makeTypeInfoBits:(ErrorCorrectionLevel *)ecLevel maskPattern:(int)maskPattern bits:(BitArray *)bits;
+ (void) makeVersionInfoBits:(int)version bits:(BitArray *)bits;
@end

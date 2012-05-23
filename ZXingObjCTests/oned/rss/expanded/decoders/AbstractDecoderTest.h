#import <SenTestingKit/SenTestingKit.h>

extern const NSString* numeric_10;
extern const NSString* numeric_12;
extern const NSString* numeric_1FNC1;
extern const NSString* numeric_FNC11;

extern const NSString* numeric2alpha;

extern const NSString* alpha_A;
extern const NSString* alpha_FNC1;
extern const NSString* alpha2numeric;
extern const NSString* alpha2isoiec646;

extern const NSString* i646_B;
extern const NSString* i646_C;
extern const NSString* i646_FNC1;
extern const NSString* isoiec646_2alpha;

extern const NSString* compressedGtin_900123456798908;
extern const NSString* compressedGtin_900000000000008;

extern const NSString* compressed15bitWeight_1750;
extern const NSString* compressed15bitWeight_11750;
extern const NSString* compressed15bitWeight_0;

extern const NSString* compressed20bitWeight_1750;

extern const NSString* compressedDate_March_12th_2010;
extern const NSString* compressedDate_End;

@interface AbstractDecoderTest : SenTestCase

- (BOOL)assertCorrectBinaryString:(NSString*)binaryString expectedNumber:(NSString*)expectedNumber error:(NSError**)error;

@end

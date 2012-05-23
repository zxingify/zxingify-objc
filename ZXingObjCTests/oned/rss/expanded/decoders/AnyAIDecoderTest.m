#import "AnyAIDecoderTest.h"

static NSString* header = @".....";

@implementation AnyAIDecoderTest

- (void)testAnyAIDecoder_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", header, numeric_10, numeric_12, numeric2alpha, alpha_A,
                    alpha2numeric, numeric_12];
  NSString* expected = @"(10)12A12";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

- (void)testAnyAIDecoder_2 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", header, numeric_10, numeric_12, numeric2alpha, alpha_A,
                    alpha2isoiec646, i646_B];
  NSString* expected = @"(10)12AB";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

- (void)testAnyAIDecoder_3 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@", header, numeric_10, numeric2alpha, alpha2isoiec646, i646_B,
                    i646_C, isoiec646_2alpha, alpha_A, alpha2numeric, numeric_10];
  NSString* expected = @"(10)BCA10";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

- (void)testAnyAIDecoder_numericFNC1_secondDigit {
  NSString* data = [NSString stringWithFormat:@"%@%@%@", header, numeric_10, numeric_1FNC1];
  NSString* expected = @"(10)1";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

- (void)testAnyAIDecoder_alphaFNC1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@%@", header, numeric_10, numeric2alpha, alpha_A, alpha_FNC1];
  NSString* expected = @"(10)A";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

- (void)testAnyAIDecoder_646FNC1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", header, numeric_10, numeric2alpha, alpha_A, isoiec646_2alpha,
                    i646_B, i646_FNC1];
  NSString* expected = @"(10)AB";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

@end

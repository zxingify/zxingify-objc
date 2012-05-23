#import "AI01_3202_3203_DecoderTest.h"

static NSString* header = @"..X.X";

@implementation AI01_3202_3203_DecoderTest

- (void)test01_3202_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@", header, compressedGtin_900123456798908, compressed15bitWeight_1750];
  NSString* expected = @"(01)90012345678908(3202)001750";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

- (void)test01_3203_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@", header, compressedGtin_900123456798908, compressed15bitWeight_11750];
  NSString* expected = @"(01)90012345678908(3203)001750";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

@end

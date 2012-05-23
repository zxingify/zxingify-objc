#import "AI01_3103_DecoderTest.h"
#import "ZXErrors.h"

static NSString* header = @"..X..";

@implementation AI01_3103_DecoderTest

- (void)test01_3103_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@", header, compressedGtin_900123456798908, compressed15bitWeight_1750];
  NSString* expected = @"(01)90012345678908(3103)001750";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

- (void)test01_3103_2 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@", header, compressedGtin_900000000000008, compressed15bitWeight_0];
  NSString* expected = @"(01)90000000000003(3103)000000";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

- (void)test01_3103_invalid {
  NSString* data = [NSString stringWithFormat:@"%@%@%@..", header, compressedGtin_900123456798908, compressed15bitWeight_1750];

  NSError* error;
  if([self assertCorrectBinaryString:data expectedNumber:@"" error:&error] || error.code != ZXNotFoundError) {
    STFail(@"NotFoundError expected");
  }
}

@end

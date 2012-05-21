#import "AI01_3X0X_1X_DecoderTest.h"

static NSString* header_310x_11 = @"..XXX...";
static NSString* header_320x_11 = @"..XXX..X";
static NSString* header_310x_13 = @"..XXX.X.";
static NSString* header_320x_13 = @"..XXX.XX";
static NSString* header_310x_15 = @"..XXXX..";
static NSString* header_320x_15 = @"..XXXX.X";
static NSString* header_310x_17 = @"..XXXXX.";
static NSString* header_320x_17 = @"..XXXXXX";

@implementation AI01_3X0X_1X_DecoderTest

- (void)test01_310X_1X_endDate {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@", header_310x_11, compressedGtin_900123456798908,
                    compressed20bitWeight_1750, compressedDate_End];
  NSString* expected = @"(01)90012345678908(3100)001750";

  [self assertCorrectBinaryString:data expectedNumber:expected];
}

- (void)test01_310X_11_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@", header_310x_11, compressedGtin_900123456798908,
                    compressed20bitWeight_1750, compressedDate_March_12th_2010];
  NSString* expected = @"(01)90012345678908(3100)001750(11)100312";

  [self assertCorrectBinaryString:data expectedNumber:expected];
}

- (void)test01_320X_11_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@", header_320x_11, compressedGtin_900123456798908,
                    compressed20bitWeight_1750, compressedDate_March_12th_2010];
  NSString* expected = @"(01)90012345678908(3200)001750(11)100312";

  [self assertCorrectBinaryString:data expectedNumber:expected];
}

- (void)test01_310X_13_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@", header_310x_13, compressedGtin_900123456798908,
                    compressed20bitWeight_1750, compressedDate_March_12th_2010];
  NSString* expected = @"(01)90012345678908(3100)001750(13)100312";

  [self assertCorrectBinaryString:data expectedNumber:expected];
}

- (void)test01_320X_13_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@", header_320x_13, compressedGtin_900123456798908,
                    compressed20bitWeight_1750, compressedDate_March_12th_2010];
  NSString* expected = @"(01)90012345678908(3200)001750(13)100312";

  [self assertCorrectBinaryString:data expectedNumber:expected];
}

- (void)test01_310X_15_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@", header_310x_15, compressedGtin_900123456798908,
                    compressed20bitWeight_1750, compressedDate_March_12th_2010];
  NSString* expected = @"(01)90012345678908(3100)001750(15)100312";

  [self assertCorrectBinaryString:data expectedNumber:expected];
}

- (void)test01_320X_15_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@", header_320x_15, compressedGtin_900123456798908,
                    compressed20bitWeight_1750, compressedDate_March_12th_2010];
  NSString* expected = @"(01)90012345678908(3200)001750(15)100312";

  [self assertCorrectBinaryString:data expectedNumber:expected];
}

- (void)test01_310X_17_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@", header_310x_17, compressedGtin_900123456798908,
                    compressed20bitWeight_1750, compressedDate_March_12th_2010];
  NSString* expected = @"(01)90012345678908(3100)001750(17)100312";

  [self assertCorrectBinaryString:data expectedNumber:expected];
}

- (void)test01_320X_17_1 {
  NSString* data = [NSString stringWithFormat:@"%@%@%@%@", header_320x_17, compressedGtin_900123456798908,
                    compressed20bitWeight_1750, compressedDate_March_12th_2010];
  NSString* expected = @"(01)90012345678908(3200)001750(17)100312";

  [self assertCorrectBinaryString:data expectedNumber:expected];
}

@end

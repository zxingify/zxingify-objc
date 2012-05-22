#import "ModeTestCase.h"
#import "ZXMode.h"
#import "ZXQRCodeVersion.h"

@implementation ModeTestCase

- (void)testForBits {
  STAssertEqualObjects([ZXMode forBits:0x00], [ZXMode terminatorMode], @"Expected terminator mode");
  STAssertEqualObjects([ZXMode forBits:0x01], [ZXMode numericMode], @"Expected numeric mode");
  STAssertEqualObjects([ZXMode forBits:0x02], [ZXMode alphanumericMode], @"Expected alphanumeric mode");
  STAssertEqualObjects([ZXMode forBits:0x04], [ZXMode byteMode], @"Expected byte mode");
  STAssertEqualObjects([ZXMode forBits:0x08], [ZXMode kanjiMode], @"Expected kanji mode");
  @try {
    [ZXMode forBits:0x10];
    STFail(@"Should have thrown an exception");
  } @catch (NSException *ex) {
    // good
  }
}

- (void)testCharacterCount {
  // Spot check a few values
  STAssertEquals([[ZXMode numericMode] characterCountBits:[ZXQRCodeVersion versionForNumber:5]], 10,
                 @"Expected character count bits to be 10");
  STAssertEquals([[ZXMode numericMode] characterCountBits:[ZXQRCodeVersion versionForNumber:26]], 12,
                 @"Expected character count bits to be 12");
  STAssertEquals([[ZXMode numericMode] characterCountBits:[ZXQRCodeVersion versionForNumber:40]], 14,
                 @"Expected character count bits to be 14");
  STAssertEquals([[ZXMode byteMode] characterCountBits:[ZXQRCodeVersion versionForNumber:7]], 8,
                 @"Expected character count bits to be 8");
  STAssertEquals([[ZXMode kanjiMode] characterCountBits:[ZXQRCodeVersion versionForNumber:8]], 8,
                 @"Expected character count bits to be 8");
}

@end

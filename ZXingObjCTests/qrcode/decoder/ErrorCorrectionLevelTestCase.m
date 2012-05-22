#import "ErrorCorrectionLevelTestCase.h"
#import "ZXErrorCorrectionLevel.h"

@implementation ErrorCorrectionLevelTestCase

- (void)testForBits {
  STAssertEqualObjects([ZXErrorCorrectionLevel forBits:0], [ZXErrorCorrectionLevel errorCorrectionLevelM],
                       @"Expected forBits:0 to equal error correction level M");
  STAssertEqualObjects([ZXErrorCorrectionLevel forBits:1], [ZXErrorCorrectionLevel errorCorrectionLevelL],
                       @"Expected forBits:1 to equal error correction level M");
  STAssertEqualObjects([ZXErrorCorrectionLevel forBits:2], [ZXErrorCorrectionLevel errorCorrectionLevelH],
                       @"Expected forBits:2 to equal error correction level M");
  STAssertEqualObjects([ZXErrorCorrectionLevel forBits:3], [ZXErrorCorrectionLevel errorCorrectionLevelQ],
                       @"Expected forBits:3 to equal error correction level M");
  @try {
    [ZXErrorCorrectionLevel forBits:4];
    STFail(@"Should have thrown an exception");
  } @catch (NSException* ex) {
    // good
  }
}

@end

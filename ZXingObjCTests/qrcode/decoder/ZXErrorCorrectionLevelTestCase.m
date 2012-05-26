/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXErrorCorrectionLevel.h"
#import "ZXErrorCorrectionLevelTestCase.h"

@implementation ZXErrorCorrectionLevelTestCase

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

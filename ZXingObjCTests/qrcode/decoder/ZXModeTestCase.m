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

#import "ZXMode.h"
#import "ZXModeTestCase.h"
#import "ZXQRCodeVersion.h"

@implementation ZXModeTestCase

- (void)testForBits {
  STAssertEqualObjects([ZXMode forBits:0x00], [ZXMode terminatorMode], @"Expected terminator mode");
  STAssertEqualObjects([ZXMode forBits:0x01], [ZXMode numericMode], @"Expected numeric mode");
  STAssertEqualObjects([ZXMode forBits:0x02], [ZXMode alphanumericMode], @"Expected alphanumeric mode");
  STAssertEqualObjects([ZXMode forBits:0x04], [ZXMode byteMode], @"Expected byte mode");
  STAssertEqualObjects([ZXMode forBits:0x08], [ZXMode kanjiMode], @"Expected kanji mode");
  if ([ZXMode forBits:0x10]) {
    STFail(@"Should have failed");
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

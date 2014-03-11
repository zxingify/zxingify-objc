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

#import "ZXModeTestCase.h"

@implementation ZXModeTestCase

- (void)testForBits {
  XCTAssertEqualObjects([ZXMode forBits:0x00], [ZXMode terminatorMode], @"Expected terminator mode");
  XCTAssertEqualObjects([ZXMode forBits:0x01], [ZXMode numericMode], @"Expected numeric mode");
  XCTAssertEqualObjects([ZXMode forBits:0x02], [ZXMode alphanumericMode], @"Expected alphanumeric mode");
  XCTAssertEqualObjects([ZXMode forBits:0x04], [ZXMode byteMode], @"Expected byte mode");
  XCTAssertEqualObjects([ZXMode forBits:0x08], [ZXMode kanjiMode], @"Expected kanji mode");
  if ([ZXMode forBits:0x10]) {
    XCTFail(@"Should have failed");
  }
}

- (void)testCharacterCount {
  // Spot check a few values
  XCTAssertEqual([[ZXMode numericMode] characterCountBits:[ZXQRCodeVersion versionForNumber:5]], 10,
                 @"Expected character count bits to be 10");
  XCTAssertEqual([[ZXMode numericMode] characterCountBits:[ZXQRCodeVersion versionForNumber:26]], 12,
                 @"Expected character count bits to be 12");
  XCTAssertEqual([[ZXMode numericMode] characterCountBits:[ZXQRCodeVersion versionForNumber:40]], 14,
                 @"Expected character count bits to be 14");
  XCTAssertEqual([[ZXMode byteMode] characterCountBits:[ZXQRCodeVersion versionForNumber:7]], 8,
                 @"Expected character count bits to be 8");
  XCTAssertEqual([[ZXMode kanjiMode] characterCountBits:[ZXQRCodeVersion versionForNumber:8]], 8,
                 @"Expected character count bits to be 8");
}

@end

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
  XCTAssertEqualObjects([ZXMode terminatorMode], [ZXMode forBits:0x00]);
  XCTAssertEqualObjects([ZXMode numericMode], [ZXMode forBits:0x01]);
  XCTAssertEqualObjects([ZXMode alphanumericMode], [ZXMode forBits:0x02]);
  XCTAssertEqualObjects([ZXMode byteMode], [ZXMode forBits:0x04]);
  XCTAssertEqualObjects([ZXMode kanjiMode], [ZXMode forBits:0x08]);
  if ([ZXMode forBits:0x10]) {
    XCTFail(@"Should have failed");
  }
}

- (void)testCharacterCount {
  // Spot check a few values
  XCTAssertEqual(10, [[ZXMode numericMode] characterCountBits:[ZXQRCodeVersion versionForNumber:5]]);
  XCTAssertEqual(12, [[ZXMode numericMode] characterCountBits:[ZXQRCodeVersion versionForNumber:26]]);
  XCTAssertEqual(14, [[ZXMode numericMode] characterCountBits:[ZXQRCodeVersion versionForNumber:40]]);
  XCTAssertEqual(9, [[ZXMode alphanumericMode] characterCountBits:[ZXQRCodeVersion versionForNumber:6]]);
  XCTAssertEqual(8, [[ZXMode byteMode] characterCountBits:[ZXQRCodeVersion versionForNumber:7]]);
  XCTAssertEqual(8, [[ZXMode kanjiMode] characterCountBits:[ZXQRCodeVersion versionForNumber:8]]);
}

@end

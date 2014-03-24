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

#import "ZXFormatInformationTestCase.h"

const int MASKED_TEST_FORMAT_INFO = 0x2BED;
const int UNMASKED_TEST_FORMAT_INFO = MASKED_TEST_FORMAT_INFO ^ 0x5412;

@implementation ZXFormatInformationTestCase

- (void)testBitsDiffering {
  XCTAssertEqual(0, [ZXFormatInformation numBitsDiffering:1 b:1]);
  XCTAssertEqual(1, [ZXFormatInformation numBitsDiffering:0 b:2]);
  XCTAssertEqual(2, [ZXFormatInformation numBitsDiffering:1 b:2]);
  XCTAssertEqual(32, [ZXFormatInformation numBitsDiffering:-1 b:0]);
}

- (void)testDecode {
  // Normal case
  ZXFormatInformation *expected =
    [ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO maskedFormatInfo2:MASKED_TEST_FORMAT_INFO];
  XCTAssertNotNil(expected);
  XCTAssertEqual(0x07, expected.dataMask);
  XCTAssertEqualObjects([ZXErrorCorrectionLevel errorCorrectionLevelQ], expected.errorCorrectionLevel);
  // where the code forgot the mask!
  XCTAssertEqualObjects(expected,
                        [ZXFormatInformation decodeFormatInformation:UNMASKED_TEST_FORMAT_INFO maskedFormatInfo2:MASKED_TEST_FORMAT_INFO]);
}

- (void)testDecodeWithBitDifference {
  ZXFormatInformation *expected =
    [ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO maskedFormatInfo2:MASKED_TEST_FORMAT_INFO];
  // 1,2,3,4 bits difference
  XCTAssertEqualObjects(expected, [ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO ^ 0x01
                                                             maskedFormatInfo2:MASKED_TEST_FORMAT_INFO ^ 0x01]);
  XCTAssertEqualObjects(expected, [ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO ^ 0x03
                                                             maskedFormatInfo2:MASKED_TEST_FORMAT_INFO ^ 0x03]);
  XCTAssertEqualObjects(expected, [ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO ^ 0x07
                                                             maskedFormatInfo2:MASKED_TEST_FORMAT_INFO ^ 0x07]);
  XCTAssertNil([ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO ^ 0x0F
                                          maskedFormatInfo2:MASKED_TEST_FORMAT_INFO ^ 0x0F]);
}

- (void)testDecodeWithMisread {
  ZXFormatInformation *expected =
    [ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO maskedFormatInfo2:MASKED_TEST_FORMAT_INFO];
  XCTAssertEqualObjects(expected, [ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO ^ 0x03
                                                             maskedFormatInfo2:MASKED_TEST_FORMAT_INFO ^ 0x0F]);
}

@end

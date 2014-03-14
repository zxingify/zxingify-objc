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
  XCTAssertEqual([ZXFormatInformation numBitsDiffering:1 b:1], 0, @"Expected numBitsDiffering 1, 1 to equal 0");
  XCTAssertEqual([ZXFormatInformation numBitsDiffering:0 b:2], 1, @"Expected numBitsDiffering 0, 2 to equal 1");
  XCTAssertEqual([ZXFormatInformation numBitsDiffering:1 b:2], 2, @"Expected numBitsDiffering 1, 2 to equal 2");
  XCTAssertEqual([ZXFormatInformation numBitsDiffering:-1 b:0], 32, @"Expected numBitsDiffering -1, 0 to equal 32");
}

- (void)testDecode {
  // Normal case
  ZXFormatInformation *expected =
    [ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO maskedFormatInfo2:MASKED_TEST_FORMAT_INFO];
  XCTAssertNotNil(expected, @"Expected expected to be non-nil");
  XCTAssertEqual(expected.dataMask, 0x07, @"Expected data mask to equal 0x07");
  XCTAssertEqualObjects(expected.errorCorrectionLevel, [ZXErrorCorrectionLevel errorCorrectionLevelQ],
                       @"Expected error correction level to be Q");
  // where the code forgot the mask!
  XCTAssertEqualObjects([ZXFormatInformation decodeFormatInformation:UNMASKED_TEST_FORMAT_INFO maskedFormatInfo2:MASKED_TEST_FORMAT_INFO], expected, @"Expected decode to be %@", expected);
}

- (void)testDecodeWithBitDifference {
  ZXFormatInformation *expected =
    [ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO maskedFormatInfo2:MASKED_TEST_FORMAT_INFO];
  // 1,2,3,4 bits difference
  XCTAssertEqualObjects([ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO ^ 0x01 maskedFormatInfo2:MASKED_TEST_FORMAT_INFO ^ 0x01], expected, @"Expected decode to be %@", expected);
  XCTAssertEqualObjects([ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO ^ 0x03 maskedFormatInfo2:MASKED_TEST_FORMAT_INFO ^ 0x03], expected, @"Expected decode to be %@", expected);
  XCTAssertEqualObjects([ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO ^ 0x07 maskedFormatInfo2:MASKED_TEST_FORMAT_INFO ^ 0x07], expected, @"Expected decode to be %@", expected);
  XCTAssertNil([ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO ^ 0x0F maskedFormatInfo2:MASKED_TEST_FORMAT_INFO ^ 0x0F], @"Expected decode to be nil");
}

- (void)testDecodeWithMisread {
  ZXFormatInformation *expected =
    [ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO maskedFormatInfo2:MASKED_TEST_FORMAT_INFO];
  XCTAssertEqualObjects([ZXFormatInformation decodeFormatInformation:MASKED_TEST_FORMAT_INFO ^ 0x03 maskedFormatInfo2:MASKED_TEST_FORMAT_INFO ^ 0x0F], expected, @"Expected decode to be %@", expected);
}

@end

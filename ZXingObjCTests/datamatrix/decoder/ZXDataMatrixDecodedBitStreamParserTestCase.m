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

#import "ZXDataMatrixDecodedBitStreamParserTestCase.h"

@implementation ZXDataMatrixDecodedBitStreamParserTestCase

- (void)testAsciiStandardDecode {
  // ASCII characters 0-127 are encoded as the value + 1
  ZXByteArray *bytes = [[ZXByteArray alloc] initWithBytes:
    (int8_t) ('a' + 1), (int8_t) ('b' + 1), (int8_t) ('c' + 1),
    (int8_t) ('A' + 1), (int8_t) ('B' + 1), (int8_t) ('C' + 1), -1];
  NSString *decodedString = [ZXDataMatrixDecodedBitStreamParser decode:bytes error:nil].text;
  XCTAssertEqualObjects(@"abcABC", decodedString);
}

- (void)testAsciiDoubleDigitDecode {
  // ASCII double digit (00 - 99) Numeric Value + 130
  ZXByteArray *bytes = [[ZXByteArray alloc] initWithBytes:
    (int8_t)       130 , (int8_t) ( 1 + 130),
    (int8_t) (98 + 130), (int8_t) (99 + 130), -1];
  NSString *decodedString = [ZXDataMatrixDecodedBitStreamParser decode:bytes error:nil].text;
  XCTAssertEqualObjects(@"00019899", decodedString);
}

@end

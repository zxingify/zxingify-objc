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

#import "ZXCode93ReaderTestCase.h"
#import "ZXCode93Reader.h"

@implementation ZXCode93ReaderTestCase

- (void)testEncode {
  NSString *expectedResult = [NSString stringWithFormat:@"Code93!\n$%%/+ :%C;[{%C%C@`%C%C%C", 0x001b, 0x007f, 0x0000, 0x007f, 0x007f, 0x007f];
  NSString *encodedResult = @"0000001010111101101000101001100101001011001001100101100101001001100101100100101000010101010000101110101101101010001001001101001101001110010101101011101011011101011101101110100101110101101001110101110110101101010001110110101100010101110110101000110101110110101000101101110110101101001101110110101100101101110110101100110101110110101011011001110110101011001101110110101001101101110110101001110101001100101101010001010111101111";

  ZXCode93Reader *reader = [[ZXCode93Reader alloc] init];
  ZXBitMatrix *matrix = [ZXBitMatrix parse:encodedResult setString:@"1" unsetString:@"0"];
  ZXBitArray *row = [[ZXBitArray alloc] initWithSize:matrix.width];
  [matrix rowAtY:0 row:row];
  ZXResult *result = [reader decodeRow:0 row:row hints:nil error:nil];
  XCTAssertEqualObjects(expectedResult, [result text]);
}

@end

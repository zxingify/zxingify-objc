/*
 * Copyright 2014 ZXing authors
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

#import "ZXCode128WriterTestCase.h"

const NSString *ZX_FNC3 = @"10111100010";
const NSString *ZX_START_CODE_B = @"11010010000";
const NSString *ZX_QUIET_SPACE = @"00000";
const NSString *ZX_STOP = @"1100011101011";

@implementation ZXCode128WriterTestCase

- (void)testEncodeWithFunc3 {
  NSString *toEncode = [NSString stringWithFormat:@"%C123", (unichar)L'\u00f3'];
  //                                                        "1"    "2"     "3"         check digit 51
  NSString *expected = [NSString stringWithFormat:@"%@%@%@10011100110110011100101100101110011101000110%@%@", ZX_QUIET_SPACE, ZX_START_CODE_B, ZX_FNC3, ZX_STOP, ZX_QUIET_SPACE];

  id<ZXWriter> writer = [[ZXCode128Writer alloc] init];
  ZXBitMatrix *result = [writer encode:toEncode format:kBarcodeFormatCode128 width:0 height:0 error:nil];

  NSMutableString *actual = [NSMutableString stringWithCapacity:result.width];
  for (int i = 0; i < result.width; i++) {
    [actual appendString:[result getX:i y:0] ? @"1" : @"0"];
  }
  XCTAssertEqualObjects(expected, actual);
}

@end

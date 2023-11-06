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

#import "ZXEAN13WriterTestCase.h"

@implementation ZXEAN13WriterTestCase

- (void)testEncode {
  NSString *testStr = @"00001010001011010011101100110010011011110100111010101011001101101100100001010111001001110100010010100000";
  ZXBitMatrix *result = [[[ZXEAN13Writer alloc] init] encode:@"5901234123457"
                                                      format:kBarcodeFormatEan13
                                                       width:(int)testStr.length
                                                      height:0
                                                       error:nil];
  for (int i = 0; i < testStr.length; i++) {
    XCTAssertEqual([result getX:i y:0], [testStr characterAtIndex:i] == '1', @"Element %d", i);
  }
}

- (void)testAddChecksumAndEncode {
  NSString *testStr = @"00001010001011010011101100110010011011110100111010101011001101101100100001010111001001110100010010100000";
  ZXBitMatrix *result = [[[ZXEAN13Writer alloc] init] encode:@"590123412345"
                                                      format:kBarcodeFormatEan13
                                                       width:(int)testStr.length
                                                      height:0
                                                       error:nil];
  for (int i = 0; i < testStr.length; i++) {
    XCTAssertEqual([result getX:i y:0], [testStr characterAtIndex:i] == '1', @"Element %d", i);
  }
}

- (void)testEncodeIllegalCharacters {
  XCTAssertThrows([[[ZXEAN13Writer alloc] init] encode:@"5901234123abc"
                                                      format:kBarcodeFormatEan13
                                                       width:0
                                                      height:0
                                                       error:nil]);
}

@end

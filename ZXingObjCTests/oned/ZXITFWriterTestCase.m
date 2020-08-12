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

#import "ZXITFWriterTestCase.h"

@implementation ZXITFWriterTestCase

- (void)testEncode {
  NSString *testStr = @"0000010101010111000111000101110100010101110001110111010001010001110100011"
  "100010101000101011100011101011101000111000101110100010101110001110100000";
  ZXBitMatrix *result = [[[ZXITFWriter alloc] init] encode:@"00123456789012"
                                                    format:kBarcodeFormatITF
                                                     width:0
                                                    height:0
                                                     error:nil];
  for (int i = 0; i < testStr.length; i++) {
    XCTAssertEqual([result getX:i y:0], [testStr characterAtIndex:i] == '1', @"Element %d", i);
  }
}

- (void)testEncodeIllegalCharacters {
  XCTAssertThrows([[[ZXITFWriter alloc] init] encode:@"00123456789abc"
                                                format:kBarcodeFormatITF
                                                 width:0
                                                height:0
                                                 error:nil]);
}

@end


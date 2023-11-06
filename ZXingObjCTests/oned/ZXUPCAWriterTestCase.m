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

#import "ZXUPCAWriterTestCase.h"

@implementation ZXUPCAWriterTestCase

- (void)testEncode {
  NSString *testStr = @"00001010100011011011101100010001011010111101111010101011100101110100100111011001101101100101110010100000";
  ZXBitMatrix *result = [[[ZXUPCAWriter alloc] init] encode:@"485963095124"
                                                     format:kBarcodeFormatUPCA
                                                      width:(int)testStr.length
                                                     height:0
                                                      error:nil];
  for (int i = 0; i < testStr.length; i++) {
    XCTAssertEqual([testStr characterAtIndex:i] == '1', [result getX:i y:0], @"Element %d", i);
  }
}

- (void)testAddChecksumAndEncode {
  NSString *testStr = @"00001010011001001001101111010100011011000101011110101010001001001000111010011100101100110110110010100000";
  ZXBitMatrix *result = [[[ZXUPCAWriter alloc] init] encode:@"12345678901"
                                                     format:kBarcodeFormatUPCA
                                                      width:(int)testStr.length
                                                     height:0
                                                      error:nil];
  for (int i = 0; i < testStr.length; i++) {
    XCTAssertEqual([testStr characterAtIndex:i] == '1', [result getX:i y:0], @"Element %d", i);
  }
}

@end

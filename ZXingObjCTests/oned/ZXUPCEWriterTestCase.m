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

#import "ZXUPCEWriterTestCase.h"

@implementation ZXUPCEWriterTestCase

- (void)testEncode {
  NSString *testStr = @"0000000000010101110010100111000101101011110110111001011101010100000000000";
  ZXBitMatrix *result = [[[ZXUPCEWriter alloc] init] encode:@"05096893"
                                                      format:kBarcodeFormatUPCE
                                                       width:(int)testStr.length
                                                      height:0
                                                       error:nil];
  for (int i = 0; i < testStr.length; i++) {
    XCTAssertEqual([result getX:i y:0], [testStr characterAtIndex:i] == '1', @"Element %d", i);
  }
}

- (void)testAddChecksumAndEncode {
  NSString *testStr = @"0000000000010101110010100111000101101011110110111001011101010100000000000";
  ZXBitMatrix *result = [[[ZXUPCEWriter alloc] init] encode:@"0509689"
                                                      format:kBarcodeFormatUPCE
                                                       width:(int)testStr.length
                                                      height:0
                                                       error:nil];
  for (int i = 0; i < testStr.length; i++) {
    XCTAssertEqual([result getX:i y:0], [testStr characterAtIndex:i] == '1', @"Element %d", i);
  }
}

- (void)testEncodeIllegalCharacters {
  XCTAssertThrows([[[ZXUPCEWriter alloc] init] encode:@"05096abc"
                                                format:kBarcodeFormatUPCE
                                                 width:0
                                                height:0
                                                 error:nil]);
}

@end

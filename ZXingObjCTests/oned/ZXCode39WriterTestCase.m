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

#import "ZXCode39WriterTestCase.h"
#import "ZXCode39Writer.h"

@implementation ZXCode39WriterTestCase

- (void)testEncode {
  NSString *testStr = @"000001001011011010110101001011010110100101101101101001010101011001011011010110010101"
  "011011001010101010011011011010100110101011010011010101011001101011010101001101011010"
  "100110110110101001010101101001101101011010010101101101001010101011001101101010110010"
  "101101011001010101101100101100101010110100110101011011001101010101001011010110110010"
  "110101010011011010101010011011010110100101011010110010101101101100101010101001101011"
  "01101001101010101100110101010100101101101101001011010101100101101010010110110100000\n";

  ZXBitMatrix *matrix = [[[ZXCode39Writer alloc] init] encode:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                                                       format:kBarcodeFormatCode39
                                                        width:0
                                                       height:0
                                                        error:nil];
  XCTAssertEqualObjects(testStr, [matrix descriptionWithSetString:@"1" unsetString:@"0"]);
}

@end

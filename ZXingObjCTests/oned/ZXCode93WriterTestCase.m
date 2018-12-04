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

#import "ZXCode93WriterTestCase.h"
#import "ZXCode93Writer.h"

@implementation ZXCode93WriterTestCase

- (void)testEncode {
  [self doTest:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      expected:@"000001010111101101010001101001001101000101100101001100100101100010101011010001011001"
   "001011000101001101001000110101010110001010011001010001101001011001000101101101101001"
   "101100101101011001101001101100101101100110101011011001011001101001101101001110101000"
   "101001010010001010001001010000101001010001001001001001000101010100001000100101000010"
   "10100111010101000010101011110100000\n"];

  [self doTest:[NSString stringWithFormat:@"%C%C%C%C%C $%%+!,09:;@AZ[_`az{%C", 0x0000, 0x0001, 0x001a, 0x001b, 0x001f, 0x007f]
      expected:@"00000" @"101011110"
   @"111011010" @"110010110" @"100100110" @"110101000" @ // bU aA
   "100100110" @"100111010" @"111011010" @"110101000" @ // aZ bA
   "111011010" @"110010010" @"111010010" @"111001010" @ // bE space $
   "110101110" @"101110110" @"111010110" @"110101000" @ // % + cA
   "111010110" @"101011000" @"100010100" @"100001010" @ // cL 0 9
   "111010110" @"100111010" @"111011010" @"110001010" @ // cZ bF
   "111011010" @"110011010" @"110101000" @"100111010" @ // bV A Z
   "111011010" @"100011010" @"111011010" @"100101100" @ // bK bO
   "111011010" @"101101100" @"100110010" @"110101000" @ // bW dA
   "100110010" @"100111010" @"111011010" @"100010110" @ // dZ bP
   "111011010" @"110100110" @ // bT
   "110100010" @"110101100" @ // checksum: 12 28
   "101011110" @"100000\n"];
}

- (void)doTest:(NSString *)input expected:(NSString *)expected {
  ZXBitMatrix *matrix = [[[ZXCode93Writer alloc] init] encode:input
                                                       format:kBarcodeFormatCode93
                                                        width:0
                                                       height:0
                                                        error:nil];
  XCTAssertEqualObjects(expected, [matrix descriptionWithSetString:@"1" unsetString:@"0"]);
}

@end

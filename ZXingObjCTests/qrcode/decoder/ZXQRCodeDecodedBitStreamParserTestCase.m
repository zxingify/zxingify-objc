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

#import "ZXBitSourceBuilder.h"
#import "ZXQRCodeDecodedBitStreamParserTestCase.h"

@implementation ZXQRCodeDecodedBitStreamParserTestCase

- (void)testSimpleByteMode {
  ZXBitSourceBuilder *builder = [[ZXBitSourceBuilder alloc] init];
  [builder write:0x04 numBits:4]; // Byte mode
  [builder write:0x03 numBits:8]; // 3 bytes
  [builder write:0xF1 numBits:8];
  [builder write:0xF2 numBits:8];
  [builder write:0xF3 numBits:8];
  NSString *result = [[ZXQRCodeDecodedBitStreamParser decode:[builder toByteArray]
                                                     version:[ZXQRCodeVersion versionForNumber:1]
                                                     ecLevel:nil hints:nil error:nil] text];
  NSString *expected = @"\u00f1\u00f2\u00f3";
  XCTAssertEqualObjects(result, expected, @"Expected %@ to equal %@", result, expected);
}

- (void)testSimpleSJIS {
  ZXBitSourceBuilder *builder = [[ZXBitSourceBuilder alloc] init];
  [builder write:0x04 numBits:4]; // Byte mode
  [builder write:0x04 numBits:8]; // 4 bytes
  [builder write:0xA1 numBits:8];
  [builder write:0xA2 numBits:8];
  [builder write:0xA3 numBits:8];
  [builder write:0xD0 numBits:8];
  NSString *result = [[ZXQRCodeDecodedBitStreamParser decode:[builder toByteArray]
                                                     version:[ZXQRCodeVersion versionForNumber:1]
                                                     ecLevel:nil hints:nil error:nil] text];
  NSString *expected = @"\uff61\uff62\uff63\uff90";
  XCTAssertEqualObjects(result, expected, @"Expected %@ to equal %@", result, expected);
}

- (void)testECI {
  ZXBitSourceBuilder *builder = [[ZXBitSourceBuilder alloc] init];
  [builder write:0x07 numBits:4]; // ECI mode
  [builder write:0x02 numBits:8]; // ECI 2 = CP437 encoding
  [builder write:0x04 numBits:4]; // Byte mode
  [builder write:0x03 numBits:8]; // 3 bytes
  [builder write:0xA1 numBits:8];
  [builder write:0xA2 numBits:8];
  [builder write:0xA3 numBits:8];
  NSString *result = [[ZXQRCodeDecodedBitStreamParser decode:[builder toByteArray]
                                                     version:[ZXQRCodeVersion versionForNumber:1]
                                                     ecLevel:nil hints:nil error:nil] text];
  NSString *expected = @"\u00ed\u00f3\u00fa";
  XCTAssertEqualObjects(result, expected, @"Expected %@ to equal %@", result, expected);
}

- (void)testHanzi {
  ZXBitSourceBuilder *builder = [[ZXBitSourceBuilder alloc] init];
  [builder write:0x0D numBits:4]; // Hanzi mode
  [builder write:0x01 numBits:4]; // Subset 1 = GB2312 encoding
  [builder write:0x01 numBits:8]; // 1 characters
  [builder write:0x03C1 numBits:13];
  NSString *result = [[ZXQRCodeDecodedBitStreamParser decode:[builder toByteArray]
                                                     version:[ZXQRCodeVersion versionForNumber:1]
                                                     ecLevel:nil hints:nil error:nil] text];
  NSString *expected = @"\u963f";
  XCTAssertEqualObjects(result, expected, @"Expected %@ to equal %@", result, expected);
}

@end

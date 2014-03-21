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

#import "ZXCodaBarWriterTestCase.h"

@implementation ZXCodaBarWriterTestCase

- (void)testEncode {
  [self doTest:@"B515-3/B"
      expected:@"00000"
                "1001001011"
                "0110101001"
                "0101011001"
                "0110101001"
                "0101001101"
                "0110010101"
                "01101101011"
                "01001001011"
                "00000"];
}

- (void)testEncode2 {
  [self doTest:@"T123T"
      expected:@"00000"
                "1011001001"
                "0101011001"
                "0101001011"
                "0110010101"
                "01011001001"
                "00000"];
}

- (void)testAltStartEnd {
  XCTAssertEqualObjects([self encode:@"T123456789-$T"], [self encode:@"A123456789-$A"]);
}

- (void)doTest:(NSString *)input expected:(NSString *)expected {
  ZXBitMatrix *result = [self encode:input];
  NSMutableString *actual = [NSMutableString stringWithCapacity:result.width];
  for (int i = 0; i < result.width; i++) {
    [actual appendString:[result getX:i y:0] ? @"1" : @"0"];
  }
  XCTAssertEqualObjects(actual, expected);
}

- (ZXBitMatrix *)encode:(NSString *)input {
  return [[[ZXCodaBarWriter alloc] init] encode:input format:kBarcodeFormatCodabar width:0 height:0 error:nil];
}

@end

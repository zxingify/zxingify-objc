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

#import "RSSExpandedImage2stringTestCase.h"

@implementation RSSExpandedImage2stringTestCase

- (void)testDecodeRow2string_1 {
  [self assertCorrectImage2string:@"1.png" expected:@"(11)100224(17)110224(3102)000100"];
}

- (void)testDecodeRow2string_2 {
  [self assertCorrectImage2string:@"2.png" expected:@"(01)90012345678908(3103)001750"];
}

- (void)testDecodeRow2string_3 {
  [self assertCorrectImage2string:@"3.png" expected:@"(10)12A"];
}

- (void)testDecodeRow2string_4 {
  [self assertCorrectImage2string:@"4.png" expected:@"(01)98898765432106(3202)012345(15)991231"];
}

- (void)testDecodeRow2string_5 {
  [self assertCorrectImage2string:@"5.png" expected:@"(01)90614141000015(3202)000150"];
}

- (void)testDecodeRow2string_7 {
  [self assertCorrectImage2string:@"7.png" expected:@"(10)567(11)010101"];
}

- (void)testDecodeRow2string_10 {
  NSString *expected = @"(01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456(423)012345678901";
  [self assertCorrectImage2string:@"10.png" expected:expected];
}

- (void)testDecodeRow2string_11 {
  [self assertCorrectImage2string:@"11.png" expected:@"(01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456"];
}

- (void)testDecodeRow2string_12 {
  [self assertCorrectImage2string:@"12.png" expected:@"(01)98898765432106(3103)001750"];
}

- (void)testDecodeRow2string_13 {
  [self assertCorrectImage2string:@"13.png" expected:@"(01)90012345678908(3922)795"];
}

- (void)testDecodeRow2string_14 {
  [self assertCorrectImage2string:@"14.png" expected:@"(01)90012345678908(3932)0401234"];
}

- (void)testDecodeRow2string_15 {
  [self assertCorrectImage2string:@"15.png" expected:@"(01)90012345678908(3102)001750(11)100312"];
}

- (void)testDecodeRow2string_16 {
  [self assertCorrectImage2string:@"16.png" expected:@"(01)90012345678908(3202)001750(11)100312"];
}

- (void)testDecodeRow2string_17 {
  [self assertCorrectImage2string:@"17.png" expected:@"(01)90012345678908(3102)001750(13)100312"];
}

- (void)testDecodeRow2string_18 {
  [self assertCorrectImage2string:@"18.png" expected:@"(01)90012345678908(3202)001750(13)100312"];
}

- (void)testDecodeRow2string_19 {
  [self assertCorrectImage2string:@"19.png" expected:@"(01)90012345678908(3102)001750(15)100312"];
}

- (void)testDecodeRow2string_20 {
  [self assertCorrectImage2string:@"20.png" expected:@"(01)90012345678908(3202)001750(15)100312"];
}

- (void)testDecodeRow2string_21 {
  [self assertCorrectImage2string:@"21.png" expected:@"(01)90012345678908(3102)001750(17)100312"];
}

- (void)testDecodeRow2string_22 {
  [self assertCorrectImage2string:@"22.png" expected:@"(01)90012345678908(3202)001750(17)100312"];
}

- (void)testDecodeRow2string_25 {
  [self assertCorrectImage2string:@"25.png" expected:@"(10)123"];
}

- (void)testDecodeRow2string_26 {
  [self assertCorrectImage2string:@"26.png" expected:@"(10)5678(11)010101"];
}

- (void)testDecodeRow2string_27 {
  [self assertCorrectImage2string:@"27.png" expected:@"(10)1098-1234"];
}

- (void)testDecodeRow2string_28 {
  [self assertCorrectImage2string:@"28.png" expected:@"(10)1098/1234"];
}

- (void)testDecodeRow2string_29 {
  [self assertCorrectImage2string:@"29.png" expected:@"(10)1098.1234"];
}

- (void)testDecodeRow2string_30 {
  [self assertCorrectImage2string:@"30.png" expected:@"(10)1098*1234"];
}

- (void)testDecodeRow2string_31 {
  [self assertCorrectImage2string:@"31.png" expected:@"(10)1098,1234"];
}

- (void)testDecodeRow2string_32 {
  [self assertCorrectImage2string:@"32.png" expected:@"(15)991231(3103)001750(10)12A(422)123(21)123456(423)0123456789012"];
}

- (void)assertCorrectImage2string:(NSString *)filename expected:(NSString *)expected {
  NSString *path = [@"Resources/blackbox/rssexpanded-1/" stringByAppendingString:filename];

  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];

  ZXImage *image = [[ZXImage alloc] initWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:path withExtension:nil]];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  int rowNumber = binaryMap.height / 2;
  ZXBitArray *row = [binaryMap blackRow:rowNumber row:nil error:nil];

  NSError *error = nil;
  ZXResult *result = [rssExpandedReader decodeRow:rowNumber row:row hints:nil error:&error];
  if (!result) {
    XCTFail(@"%@", [error description]);
    return;
  }

  XCTAssertEqual(result.barcodeFormat, kBarcodeFormatRSSExpanded, @"Expected barcode format to be kBarcodeFormatRSSExpanded");
  XCTAssertEqualObjects(result.text, expected, @"Expected %@ to equal %@", result.text, expected);
}

@end

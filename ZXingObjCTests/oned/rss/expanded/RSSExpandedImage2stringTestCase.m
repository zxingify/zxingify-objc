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
#import "ZXBitArrayBuilder.h"
#import "ZXBinaryBitmap.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXGlobalHistogramBinarizer.h"
#import "ZXImage.h"
#import "ZXResult.h"
#import "ZXRSSExpandedReader.h"

@interface RSSExpandedImage2stringTestCase ()

- (void)assertCorrectImage2string:(NSString *)path expected:(NSString *)expected;

@end

@implementation RSSExpandedImage2stringTestCase

- (void)testDecodeRow2string_1 {
  NSString *path = @"Resources/blackbox/rssexpanded-1/1.png";
  NSString *expected = @"(11)100224(17)110224(3102)000100";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_2 {
  NSString *path = @"Resources/blackbox/rssexpanded-1/2.png";
  NSString *expected = @"(01)90012345678908(3103)001750";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_3 {
  NSString *path = @"Resources/blackbox/rssexpanded-1/3.png";
  NSString *expected = @"(10)12A";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_4 {
  NSString *path = @"Resources/blackbox/rssexpanded-1/4.png";
  NSString *expected = @"(01)98898765432106(3202)012345(15)991231";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_5 {
  NSString *path = @"Resources/blackbox/rssexpanded-1/5.png";
  NSString *expected = @"(01)90614141000015(3202)000150";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_7 {
  NSString *path = @"Resources/blackbox/rssexpanded-1/7.png";
  NSString *expected = @"(10)567(11)010101";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_10 {
  NSString *path = @"Resources/blackbox/rssexpanded-1/10.png";
  NSString *expected = @"(01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456(423)012345678901";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_11 {
  NSString *expected = @"(01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456";
  NSString *path = @"Resources/blackbox/rssexpanded-1/11.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_12 {
  NSString *expected = @"(01)98898765432106(3103)001750";
  NSString *path = @"Resources/blackbox/rssexpanded-1/12.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_13 {
  NSString *expected = @"(01)90012345678908(3922)795";
  NSString *path = @"Resources/blackbox/rssexpanded-1/13.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_14 {
  NSString *expected = @"(01)90012345678908(3932)0401234";
  NSString *path = @"Resources/blackbox/rssexpanded-1/14.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_15 {
  NSString *expected = @"(01)90012345678908(3102)001750(11)100312";
  NSString *path = @"Resources/blackbox/rssexpanded-1/15.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_16 {
  NSString *expected = @"(01)90012345678908(3202)001750(11)100312";
  NSString *path = @"Resources/blackbox/rssexpanded-1/16.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_17 {
  NSString *expected = @"(01)90012345678908(3102)001750(13)100312";
  NSString *path = @"Resources/blackbox/rssexpanded-1/17.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_18 {
  NSString *expected = @"(01)90012345678908(3202)001750(13)100312";
  NSString *path = @"Resources/blackbox/rssexpanded-1/18.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_19 {
  NSString *expected = @"(01)90012345678908(3102)001750(15)100312";
  NSString *path = @"Resources/blackbox/rssexpanded-1/19.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_20 {
  NSString *expected = @"(01)90012345678908(3202)001750(15)100312";
  NSString *path = @"Resources/blackbox/rssexpanded-1/20.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_21 {
  NSString *expected = @"(01)90012345678908(3102)001750(17)100312";
  NSString *path = @"Resources/blackbox/rssexpanded-1/21.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_22 {
  NSString *expected = @"(01)90012345678908(3202)001750(17)100312";
  NSString *path = @"Resources/blackbox/rssexpanded-1/22.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_25 {
  NSString *expected = @"(10)123";
  NSString *path = @"Resources/blackbox/rssexpanded-1/25.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_26 {
  NSString *expected = @"(10)5678(11)010101";
  NSString *path = @"Resources/blackbox/rssexpanded-1/26.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_27 {
  NSString *expected = @"(10)1098-1234";
  NSString *path = @"Resources/blackbox/rssexpanded-1/27.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_28 {
  NSString *expected = @"(10)1098/1234";
  NSString *path = @"Resources/blackbox/rssexpanded-1/28.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_29 {
  NSString *expected = @"(10)1098.1234";
  NSString *path = @"Resources/blackbox/rssexpanded-1/29.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_30 {
  NSString *expected = @"(10)1098*1234";
  NSString *path = @"Resources/blackbox/rssexpanded-1/30.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_31 {
  NSString *expected = @"(10)1098,1234";
  NSString *path = @"Resources/blackbox/rssexpanded-1/31.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)testDecodeRow2string_32 {
  NSString *expected = @"(15)991231(3103)001750(10)12A(422)123(21)123456(423)0123456789012";
  NSString *path = @"Resources/blackbox/rssexpanded-1/32.png";

  [self assertCorrectImage2string:path expected:expected];
}

- (void)assertCorrectImage2string:(NSString *)path expected:(NSString *)expected {
  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];

  ZXImage *image = [[ZXImage alloc] initWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:path withExtension:nil]];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  int rowNumber = binaryMap.height / 2;
  ZXBitArray *row = [binaryMap blackRow:rowNumber row:nil error:nil];

  NSError *error = nil;
  ZXResult *result = [rssExpandedReader decodeRow:rowNumber row:row hints:nil error:&error];
  if (!result) {
    STFail([error description]);
    return;
  }

  STAssertEquals(result.barcodeFormat, kBarcodeFormatRSSExpanded, @"Expected barcode format to be kBarcodeFormatRSSExpanded");
  STAssertEqualObjects(result.text, expected, @"Expected %@ to equal %@", result.text, expected);
}

@end

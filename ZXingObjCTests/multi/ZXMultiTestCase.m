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

#import "ZXMultiTestCase.h"

@implementation ZXMultiTestCase

- (void)testMulti {
  NSString *testBase = @"Resources/blackbox/multi-1";
  NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
  NSString *pathForResource = [classBundle pathForResource:@"1" ofType:@"png" inDirectory:testBase];
  NSURL *testImageURL = [NSURL fileURLWithPath:pathForResource];

  ZXImage *testImage = [[ZXImage alloc] initWithURL:testImageURL];
  ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:testImage.cgimage];
  ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXHybridBinarizer alloc] initWithSource:source]];

  ZXGenericMultipleBarcodeReader *multiReader = [[ZXGenericMultipleBarcodeReader alloc] initWithDelegate:[ZXMultiFormatReader reader]];
  NSArray<ZXResult *> *results = [multiReader decodeMultiple:bitmap error:nil];
  XCTAssertNotNil(results);
  XCTAssertEqual(2, results.count);

  XCTAssertEqualObjects(@"031415926531", results[0].text);
  XCTAssertEqual(kBarcodeFormatUPCA, results[0].barcodeFormat);

  XCTAssertEqualObjects(@"www.airtable.com/jobs", results[1].text);
  XCTAssertEqual(kBarcodeFormatQRCode, results[1].barcodeFormat);
}

- (void)testMultiTryHarder {
    NSString *testBase = @"Resources/blackbox/multi-1";
    NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
    NSString *pathForResource = [classBundle pathForResource:@"1" ofType:@"png" inDirectory:testBase];
    NSURL *testImageURL = [NSURL fileURLWithPath:pathForResource];

    ZXImage *testImage = [[ZXImage alloc] initWithURL:testImageURL];
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:testImage.cgimage];
    ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXHybridBinarizer alloc] initWithSource:source]];

    ZXGenericMultipleBarcodeReader *multiReader = [[ZXGenericMultipleBarcodeReader alloc] initWithDelegate:[ZXMultiFormatReader reader]];

    ZXDecodeHints *hints = [ZXDecodeHints hints];
    hints.tryHarder = YES;

    NSArray<ZXResult *> *results = [multiReader decodeMultiple:bitmap hints:hints error:nil];
    XCTAssertNotNil(results);
    XCTAssertEqual(2, results.count);

    XCTAssertEqualObjects(@"www.airtable.com/jobs", results[0].text);
    XCTAssertEqual(kBarcodeFormatQRCode, results[0].barcodeFormat);

    XCTAssertEqualObjects(@"031415926531", results[1].text);
    XCTAssertEqual(kBarcodeFormatUPCA, results[1].barcodeFormat);
}

@end

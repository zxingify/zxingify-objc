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

#import "ZXGenericMultipleBarcodeReaderTestCase.h"

@implementation ZXGenericMultipleBarcodeReaderTestCase

- (id)initWithInvocation:(NSInvocation *)invocation {
  ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
  ZXGenericMultipleBarcodeReader *multiReader = [[ZXGenericMultipleBarcodeReader alloc] initWithDelegate:reader];
  NSArray *expectedFormats = @[@(kBarcodeFormatCode39),
                               @(kBarcodeFormatCode128),
                               @(kBarcodeFormatEan13),
                               @(kBarcodeFormatQRCode),
                               @(kBarcodeFormatUPCE)];

  self = [super initWithInvocation:invocation
                testBasePathSuffix:@"Resources/blackbox/multi"
             multipleBarcodeReader:multiReader
                   expectedFormats:expectedFormats];
  if (self) {
    _reader = reader;
    [self addTest:1 tryHarderCount:1 rotation:0.0f];
    [self addTest:1 tryHarderCount:1 rotation:90.0f];
    [self addTest:1 tryHarderCount:1 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

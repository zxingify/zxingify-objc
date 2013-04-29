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

#import "PDF417BlackBox2TestCase.h"
#import "ZXMultiFormatReader.h"

/**
 * This test contains 480x240 images captured from an Android device at preview resolution.
 */
@implementation PDF417BlackBox2TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/pdf417-2"
                     barcodeReader:[[ZXMultiFormatReader alloc] init]
                    expectedFormat:kBarcodeFormatPDF417];

  if (self) {
    [self addTest:19 tryHarderCount:19 maxMisreads:0 maxTryHarderMisreads:0 rotation:0.0f];
    [self addTest:17 tryHarderCount:17 maxMisreads:0 maxTryHarderMisreads:0 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

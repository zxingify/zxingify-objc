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

#import "ZXQRCodeBlackBox6TestCase.h"

@implementation ZXQRCodeBlackBox6TestCase

/**
 * These tests are supplied by Tim Gernat and test finder pattern detection at small size and under
 * rotation, which was a weak spot.
 */
- (id)initWithInvocation:(NSInvocation *)invocation {
  self = [super initWithInvocation:invocation
                testBasePathSuffix:@"Resources/blackbox/qrcode-6"
                     barcodeReader:[[ZXMultiFormatReader alloc] init]
                    expectedFormat:kBarcodeFormatQRCode];

  if (self) {
    [self addTest:15 tryHarderCount:15 rotation:0.0f];
    [self addTest:14 tryHarderCount:14 rotation:90.0f];
    [self addTest:13 tryHarderCount:13 rotation:180.0f];
    [self addTest:14 tryHarderCount:14 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

- (void)testBlackBox2 {
  ZXCGImageLuminanceSourceInfo *info = [[ZXCGImageLuminanceSourceInfo alloc] initWithShades:16];
  [self setLuminanceSourceInfo:info];
  [self setShouldTruncateNewline:TRUE];
  
  [super runTests];
}

@end

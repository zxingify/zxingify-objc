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

#import "ZXCode39ExtendedBlackBox2TestCase.h"

@implementation ZXCode39ExtendedBlackBox2TestCase

- (id)initWithInvocation:(NSInvocation *)invocation {
  self = [super initWithInvocation:invocation
                testBasePathSuffix:@"Resources/blackbox/code39-2"
                     barcodeReader:[[ZXCode39Reader alloc] initUsingCheckDigit:NO extendedMode:YES]
                    expectedFormat:kBarcodeFormatCode39];

  if (self) {
    [self addTest:2 tryHarderCount:2 rotation:0.0f];
    [self addTest:2 tryHarderCount:2 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

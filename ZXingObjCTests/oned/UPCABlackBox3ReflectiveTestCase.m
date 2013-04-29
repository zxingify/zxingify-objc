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

#import "UPCABlackBox3ReflectiveTestCase.h"
#import "ZXMultiFormatReader.h"

@implementation UPCABlackBox3ReflectiveTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/upca-3"
                     barcodeReader:[[ZXMultiFormatReader alloc] init]
                    expectedFormat:kBarcodeFormatUPCA];

  if (self) {
    [self addTest:7 tryHarderCount:9 maxMisreads:0 maxTryHarderMisreads:2 rotation:0.0f];
    [self addTest:8 tryHarderCount:9 maxMisreads:0 maxTryHarderMisreads:2 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

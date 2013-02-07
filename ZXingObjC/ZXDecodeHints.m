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

#import "ZXDecodeHints.h"
#import "ZXResultPointCallback.h"

@interface ZXDecodeHints ()

@property (nonatomic, retain) NSMutableArray *barcodeFormats;

@end

@implementation ZXDecodeHints

@synthesize assumeCode39CheckDigit;
@synthesize allowedLengths;
@synthesize barcodeFormats;
@synthesize encoding;
@synthesize other;
@synthesize pureBarcode;
@synthesize resultPointCallback;
@synthesize tryHarder;

- (id)init {
  if (self = [super init]) {
    self.barcodeFormats = [NSMutableArray array];
  }

  return self;
}

+ (id)hints {
  return [[[self alloc] init] autorelease];
}

- (id)copyWithZone:(NSZone *)zone {
  ZXDecodeHints *result = [[[self class] allocWithZone:zone] init];
  if (result) {
    result.assumeCode39CheckDigit = self.assumeCode39CheckDigit;
    result.allowedLengths = [[self.allowedLengths copy] autorelease];

    for (NSNumber *formatNumber in self.barcodeFormats) {
      [result addPossibleFormat:[formatNumber intValue]];
    }

    result.encoding = self.encoding;
    result.other = self.other;
    result.pureBarcode = self.pureBarcode;
    result.resultPointCallback = self.resultPointCallback;
    result.tryHarder = self.tryHarder;
  }

  return result;
}

- (void)dealloc {
  [allowedLengths release];
  [barcodeFormats release];
  [other release];
  [resultPointCallback release];

  [super dealloc];
}

- (void)addPossibleFormat:(ZXBarcodeFormat)format {
  [self.barcodeFormats addObject:[NSNumber numberWithInt:format]];
}

- (BOOL)containsFormat:(ZXBarcodeFormat)format {
  return [self.barcodeFormats containsObject:[NSNumber numberWithInt:format]];
}

- (int)numberOfPossibleFormats {
  return self.barcodeFormats.count;
}

- (void)removePossibleFormat:(ZXBarcodeFormat)format {
  [self.barcodeFormats removeObject:[NSNumber numberWithInt:format]];
}

@end
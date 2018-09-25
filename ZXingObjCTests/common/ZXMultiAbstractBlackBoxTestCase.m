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

#import "ZXMultiAbstractBlackBoxTestCase.h"

@implementation ZXMultiAbstractBlackBoxTestCase

@synthesize multipleBarcodeReader = _multipleBarcodeReader;
@synthesize expectedFormat = _expectedFormat;
@synthesize testBase = _testBase;
@synthesize testResults = _testResults;

- (id)initWithInvocation:(NSInvocation *)invocation testBasePathSuffix:(NSString *)testBasePathSuffix multipleBarcodeReader:(id<ZXMultipleBarcodeReader>)multipleBarcodeReader expectedFormats:(NSArray *)expectedFormats {
  if (self = [super initWithInvocation:invocation]) {
    _testBase = testBasePathSuffix;
    _multipleBarcodeReader = multipleBarcodeReader;
    _expectedFormats = expectedFormats;
    _testResults = [NSMutableArray array];
  }

  return self;
}

- (BOOL)decode:(ZXBinaryBitmap *)source rotation:(float)rotation expectedText:(NSString *)expectedText expectedMetadata:(NSMutableDictionary *)expectedMetadata tryHarder:(BOOL)tryHarder misread:(BOOL *)misread {
  NSArray *expectedTexts = [expectedText componentsSeparatedByString:@";"];
  NSString *suffix = [NSString stringWithFormat:@" (%@rotation: %d)", tryHarder ? @"try harder, " : @"", (int) rotation];
  *misread = NO;

  ZXDecodeHints *hints = [ZXDecodeHints hints];
  if (tryHarder) {
    hints.tryHarder = YES;
  }

  NSError *error;
  NSArray *results = [self.multipleBarcodeReader decodeMultiple:source hints:hints error:&error];
  if (!results) {
    return NO;
  }

  for (ZXResult *result in results) {
    NSPredicate *containsFormatPredicate = [NSPredicate predicateWithFormat:@"self.intValue == %d", result.barcodeFormat];
    if ([self.expectedFormats filteredArrayUsingPredicate:containsFormatPredicate].count == 0) {
      NSLog(@"Format mismatch: expected '%@' but got '%@'%@",
            [[self class] barcodeFormatAsString:self.expectedFormat], [[self class] barcodeFormatAsString:result.barcodeFormat], suffix);
      *misread = YES;
      return NO;
    }

    NSString *resultText = result.text;
    if (![expectedTexts containsObject:resultText]) {
      NSLog(@"Content mismatch: expected '%@' but got '%@'%@", expectedText, resultText, suffix);
      *misread = YES;
      return NO;
    }

    NSMutableDictionary *resultMetadata = result.resultMetadata;
    for (id keyObj in expectedMetadata.allKeys) {
      ZXResultMetadataType key = [keyObj intValue];
      id expectedValue = expectedMetadata[keyObj];
      id actualValue = resultMetadata[keyObj];
      if (![expectedValue isEqual:actualValue]) {
        NSLog(@"Metadata mismatch: for key '%d' expected '%@' but got '%@'", key, expectedValue, actualValue);
        *misread = YES;
        return NO;
      }
    }
  }

  return YES;
}

@end

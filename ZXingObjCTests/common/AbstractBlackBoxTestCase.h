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

#import <SenTestingKit/SenTestingKit.h>
#import "ZXBarcodeFormat.h"
#import "ZXDecodeHints.h"
#import "ZXImage.h"
#import "ZXReader.h"

@interface AbstractBlackBoxTestCase : SenTestCase

@property (nonatomic, strong, readonly) id<ZXReader> barcodeReader;

- (id)initWithInvocation:(NSInvocation *)anInvocation testBasePathSuffix:(NSString *)testBasePathSuffix barcodeReader:(id<ZXReader>)barcodeReader expectedFormat:(ZXBarcodeFormat)expectedFormat;
+ (NSString *)barcodeFormatAsString:(ZXBarcodeFormat)format;
- (void)addTest:(int)mustPassCount tryHarderCount:(int)tryHarderCount rotation:(float)rotation;
- (void)addTest:(int)mustPassCount tryHarderCount:(int)tryHarderCount maxMisreads:(int)maxMisreads maxTryHarderMisreads:(int)maxTryHarderMisreads rotation:(float)rotation;
- (void)runTests;

- (NSArray *)imageFiles;
- (ZXImage *)rotateImage:(ZXImage *)original degrees:(float)degrees;

@end

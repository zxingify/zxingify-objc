/*
 * Copyright 2013 ZXing authors
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

#import "ZXDimension.h"
#import "ZXSymbolInfo.h"
#import "ZXSymbolInfoTestCase.h"
#import "ZXSymbolShapeHint.h"

@implementation ZXSymbolInfoTestCase

- (void)testSymbolInfo {
  ZXSymbolInfo *info = [ZXSymbolInfo lookup:3];
  STAssertEquals(info.errorCodewords, 5, @"");
  STAssertEquals(info.matrixWidth, 8, @"");
  STAssertEquals(info.matrixHeight, 8, @"");
  STAssertEquals(info.symbolWidth, 10, @"");
  STAssertEquals(info.symbolHeight, 10, @"");

  info = [ZXSymbolInfo lookup:3 shape:[ZXSymbolShapeHint forceRectangle]];
  STAssertEquals(info.errorCodewords, 7, @"");
  STAssertEquals(info.matrixWidth, 16, @"");
  STAssertEquals(info.matrixHeight, 6, @"");
  STAssertEquals(info.symbolWidth, 18, @"");
  STAssertEquals(info.symbolHeight, 8, @"");

  info = [ZXSymbolInfo lookup:9];
  STAssertEquals(info.errorCodewords, 11, @"");
  STAssertEquals(info.matrixWidth, 14, @"");
  STAssertEquals(info.matrixHeight, 6, @"");
  STAssertEquals(info.symbolWidth, 32, @"");
  STAssertEquals(info.symbolHeight, 8, @"");

  info = [ZXSymbolInfo lookup:9 shape:[ZXSymbolShapeHint forceSquare]];
  STAssertEquals(info.errorCodewords, 12, @"");
  STAssertEquals(info.matrixWidth, 14, @"");
  STAssertEquals(info.matrixHeight, 14, @"");
  STAssertEquals(info.symbolWidth, 16, @"");
  STAssertEquals(info.symbolHeight, 16, @"");

  @try {
    [ZXSymbolInfo lookup:1559];
    STFail(@"There's no rectangular symbol for more than 1558 data codewords");
  } @catch (NSException *exception) {
    // expected
  }

  @try {
    [ZXSymbolInfo lookup:50 shape:[ZXSymbolShapeHint forceRectangle]];
    STFail(@"There's no rectangular symbol for 50 data codewords");
  } @catch (NSException *exception) {
    // expected
  }

  info = [ZXSymbolInfo lookup:35];
  STAssertEquals(info.symbolWidth, 24, @"");
  STAssertEquals(info.symbolHeight, 24, @"");

  ZXDimension *fixedSize = [[ZXDimension alloc] initWithWidth:26 height:26];
  info = [ZXSymbolInfo lookup:35 shape:[ZXSymbolShapeHint forceNone] minSize:fixedSize maxSize:fixedSize fail:NO];
  STAssertEquals(info.symbolWidth, 26, @"");
  STAssertEquals(info.symbolHeight, 26, @"");

  info = [ZXSymbolInfo lookup:45 shape:[ZXSymbolShapeHint forceNone] minSize:fixedSize maxSize:fixedSize fail:NO];
  STAssertNil(info, @"");

  ZXDimension *minSize = fixedSize;
  ZXDimension *maxSize = [[ZXDimension alloc] initWithWidth:32 height:32];

  info = [ZXSymbolInfo lookup:35 shape:[ZXSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  STAssertEquals(info.symbolWidth, 26, @"");
  STAssertEquals(info.symbolHeight, 26, @"");

  info = [ZXSymbolInfo lookup:40 shape:[ZXSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  STAssertEquals(info.symbolWidth, 26, @"");
  STAssertEquals(info.symbolHeight, 26, @"");

  info = [ZXSymbolInfo lookup:45 shape:[ZXSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  STAssertEquals(info.symbolWidth, 32, @"");
  STAssertEquals(info.symbolHeight, 32, @"");

  info = [ZXSymbolInfo lookup:63 shape:[ZXSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  STAssertNil(info, @"");
}

@end

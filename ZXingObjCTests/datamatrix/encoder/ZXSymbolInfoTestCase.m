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

#import "ZXSymbolInfoTestCase.h"

@implementation ZXSymbolInfoTestCase

- (void)testSymbolInfo {
  ZXSymbolInfo *info = [ZXSymbolInfo lookup:3];
  XCTAssertEqual(info.errorCodewords, 5, @"");
  XCTAssertEqual(info.matrixWidth, 8, @"");
  XCTAssertEqual(info.matrixHeight, 8, @"");
  XCTAssertEqual(info.symbolWidth, 10, @"");
  XCTAssertEqual(info.symbolHeight, 10, @"");

  info = [ZXSymbolInfo lookup:3 shape:[ZXSymbolShapeHint forceRectangle]];
  XCTAssertEqual(info.errorCodewords, 7, @"");
  XCTAssertEqual(info.matrixWidth, 16, @"");
  XCTAssertEqual(info.matrixHeight, 6, @"");
  XCTAssertEqual(info.symbolWidth, 18, @"");
  XCTAssertEqual(info.symbolHeight, 8, @"");

  info = [ZXSymbolInfo lookup:9];
  XCTAssertEqual(info.errorCodewords, 11, @"");
  XCTAssertEqual(info.matrixWidth, 14, @"");
  XCTAssertEqual(info.matrixHeight, 6, @"");
  XCTAssertEqual(info.symbolWidth, 32, @"");
  XCTAssertEqual(info.symbolHeight, 8, @"");

  info = [ZXSymbolInfo lookup:9 shape:[ZXSymbolShapeHint forceSquare]];
  XCTAssertEqual(info.errorCodewords, 12, @"");
  XCTAssertEqual(info.matrixWidth, 14, @"");
  XCTAssertEqual(info.matrixHeight, 14, @"");
  XCTAssertEqual(info.symbolWidth, 16, @"");
  XCTAssertEqual(info.symbolHeight, 16, @"");

  @try {
    [ZXSymbolInfo lookup:1559];
    XCTFail(@"There's no rectangular symbol for more than 1558 data codewords");
  } @catch (NSException *exception) {
    // expected
  }

  @try {
    [ZXSymbolInfo lookup:50 shape:[ZXSymbolShapeHint forceRectangle]];
    XCTFail(@"There's no rectangular symbol for 50 data codewords");
  } @catch (NSException *exception) {
    // expected
  }

  info = [ZXSymbolInfo lookup:35];
  XCTAssertEqual(info.symbolWidth, 24, @"");
  XCTAssertEqual(info.symbolHeight, 24, @"");

  ZXDimension *fixedSize = [[ZXDimension alloc] initWithWidth:26 height:26];
  info = [ZXSymbolInfo lookup:35 shape:[ZXSymbolShapeHint forceNone] minSize:fixedSize maxSize:fixedSize fail:NO];
  XCTAssertEqual(info.symbolWidth, 26, @"");
  XCTAssertEqual(info.symbolHeight, 26, @"");

  info = [ZXSymbolInfo lookup:45 shape:[ZXSymbolShapeHint forceNone] minSize:fixedSize maxSize:fixedSize fail:NO];
  XCTAssertNil(info, @"");

  ZXDimension *minSize = fixedSize;
  ZXDimension *maxSize = [[ZXDimension alloc] initWithWidth:32 height:32];

  info = [ZXSymbolInfo lookup:35 shape:[ZXSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  XCTAssertEqual(info.symbolWidth, 26, @"");
  XCTAssertEqual(info.symbolHeight, 26, @"");

  info = [ZXSymbolInfo lookup:40 shape:[ZXSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  XCTAssertEqual(info.symbolWidth, 26, @"");
  XCTAssertEqual(info.symbolHeight, 26, @"");

  info = [ZXSymbolInfo lookup:45 shape:[ZXSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  XCTAssertEqual(info.symbolWidth, 32, @"");
  XCTAssertEqual(info.symbolHeight, 32, @"");

  info = [ZXSymbolInfo lookup:63 shape:[ZXSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  XCTAssertNil(info, @"");
}

@end

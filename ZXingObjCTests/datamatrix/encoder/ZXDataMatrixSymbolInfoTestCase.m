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

#import "ZXDataMatrixSymbolInfoTestCase.h"

@implementation ZXDataMatrixSymbolInfoTestCase

- (void)testSymbolInfo {
  ZXDataMatrixSymbolInfo *info = [ZXDataMatrixSymbolInfo lookup:3];
  XCTAssertEqual(5, info.errorCodewords);
  XCTAssertEqual(8, info.matrixWidth);
  XCTAssertEqual(8, info.matrixHeight);
  XCTAssertEqual(10, info.symbolWidth);
  XCTAssertEqual(10, info.symbolHeight);

  info = [ZXDataMatrixSymbolInfo lookup:3 shape:[ZXDataMatrixSymbolShapeHint forceRectangle]];
  XCTAssertEqual(7, info.errorCodewords);
  XCTAssertEqual(16, info.matrixWidth);
  XCTAssertEqual(6, info.matrixHeight);
  XCTAssertEqual(18, info.symbolWidth);
  XCTAssertEqual(8, info.symbolHeight);

  info = [ZXDataMatrixSymbolInfo lookup:9];
  XCTAssertEqual(11, info.errorCodewords);
  XCTAssertEqual(14, info.matrixWidth);
  XCTAssertEqual(6, info.matrixHeight);
  XCTAssertEqual(32, info.symbolWidth);
  XCTAssertEqual(8, info.symbolHeight);

  info = [ZXDataMatrixSymbolInfo lookup:9 shape:[ZXDataMatrixSymbolShapeHint forceSquare]];
  XCTAssertEqual(12, info.errorCodewords);
  XCTAssertEqual(14, info.matrixWidth);
  XCTAssertEqual(14, info.matrixHeight);
  XCTAssertEqual(16, info.symbolWidth);
  XCTAssertEqual(16, info.symbolHeight);

  @try {
    [ZXDataMatrixSymbolInfo lookup:1559];
    XCTFail(@"There's no rectangular symbol for more than 1558 data codewords");
  } @catch (NSException *exception) {
    // expected
  }

  @try {
    [ZXDataMatrixSymbolInfo lookup:50 shape:[ZXDataMatrixSymbolShapeHint forceRectangle]];
    XCTFail(@"There's no rectangular symbol for 50 data codewords");
  } @catch (NSException *exception) {
    // expected
  }

  info = [ZXDataMatrixSymbolInfo lookup:35];
  XCTAssertEqual(24, info.symbolWidth);
  XCTAssertEqual(24, info.symbolHeight);

  ZXDimension *fixedSize = [[ZXDimension alloc] initWithWidth:26 height:26];
  info = [ZXDataMatrixSymbolInfo lookup:35 shape:[ZXDataMatrixSymbolShapeHint forceNone] minSize:fixedSize maxSize:fixedSize fail:NO];
  XCTAssertEqual(26, info.symbolWidth);
  XCTAssertEqual(26, info.symbolHeight);

  info = [ZXDataMatrixSymbolInfo lookup:45 shape:[ZXDataMatrixSymbolShapeHint forceNone] minSize:fixedSize maxSize:fixedSize fail:NO];
  XCTAssertNil(info);

  ZXDimension *minSize = fixedSize;
  ZXDimension *maxSize = [[ZXDimension alloc] initWithWidth:32 height:32];

  info = [ZXDataMatrixSymbolInfo lookup:35 shape:[ZXDataMatrixSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  XCTAssertEqual(26, info.symbolWidth);
  XCTAssertEqual(26, info.symbolHeight);

  info = [ZXDataMatrixSymbolInfo lookup:40 shape:[ZXDataMatrixSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  XCTAssertEqual(26, info.symbolWidth);
  XCTAssertEqual(26, info.symbolHeight);

  info = [ZXDataMatrixSymbolInfo lookup:45 shape:[ZXDataMatrixSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  XCTAssertEqual(32, info.symbolWidth);
  XCTAssertEqual(32, info.symbolHeight);

  info = [ZXDataMatrixSymbolInfo lookup:63 shape:[ZXDataMatrixSymbolShapeHint forceNone] minSize:minSize maxSize:maxSize fail:NO];
  XCTAssertNil(info);
}

@end

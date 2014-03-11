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

#import "ZXDataMatrixWriterTestCase.h"

@implementation ZXDataMatrixWriterTestCase

- (void)testDataMatrixImageWriter {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.dataMatrixShape = [ZXSymbolShapeHint forceSquare];

  int bigEnough = 64;
  ZXDataMatrixWriter *writer = [[ZXDataMatrixWriter alloc] init];
  ZXBitMatrix *matrix = [writer encode:@"Hello Google" format:kBarcodeFormatDataMatrix width:bigEnough height:bigEnough hints:hints error:nil];
  XCTAssertNotNil(matrix, @"Matrix should not be nil");
  XCTAssertTrue(bigEnough >= matrix.width, @"Matrix width should be less than %d", bigEnough);
  XCTAssertTrue(bigEnough >= matrix.height, @"Matrix height should be less than %d", bigEnough);
}

- (void)testDataMatrixWriter {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.dataMatrixShape = [ZXSymbolShapeHint forceSquare];

  int bigEnough = 14;
  ZXDataMatrixWriter *writer = [[ZXDataMatrixWriter alloc] init];
  ZXBitMatrix *matrix = [writer encode:@"Hello Me" format:kBarcodeFormatDataMatrix width:bigEnough height:bigEnough hints:hints error:nil];
  XCTAssertNotNil(matrix, @"Matrix should not be nil");
  XCTAssertEqual(matrix.width, bigEnough, @"Expected matrix width to equal %d", bigEnough);
  XCTAssertEqual(matrix.height, bigEnough, @"Expected matrix height to equal %d", bigEnough);
}

- (void)testDataMatrixTooSmall {
  // The DataMatrix will not fit in this size, so the matrix should come back bigger
  int tooSmall = 8;
  ZXDataMatrixWriter *writer = [[ZXDataMatrixWriter alloc] init];
  ZXBitMatrix *matrix = [writer encode:@"http://www.google.com/" format:kBarcodeFormatDataMatrix width:tooSmall height:tooSmall hints:nil error:nil];

  XCTAssertNotNil(matrix, @"Matrix should not be nil");
  XCTAssertTrue(tooSmall < matrix.width, @"Expected matrix width to be less than %d", tooSmall);
  XCTAssertTrue(tooSmall < matrix.height, @"Expected matrix height to be less than %d", tooSmall);
}

@end

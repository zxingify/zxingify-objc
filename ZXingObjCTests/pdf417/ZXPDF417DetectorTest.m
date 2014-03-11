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

#import "ZXPDF417DetectorTest.h"

const int BIT_SET_INDEX_LEN = 4;
const int BIT_SET_INDEX[BIT_SET_INDEX_LEN] = { 1, 2, 3, 5 };

const int BIT_MATRIX_POINTS_LEN = 6;
const int BIT_MATRIX_POINTS[BIT_MATRIX_POINTS_LEN] = { 1, 2, 2, 0, 3, 1 };

@implementation ZXPDF417DetectorTest

- (void)testMirror {
  [self testMirror:7];
  [self testMirror:8];
}

- (void)testMirror:(int)size {
  ZXBitArray *result = [[ZXBitArray alloc] initWithSize:size];
  [ZXPDF417Detector mirror:[self input:size] result:result];

  ZXBitArray *expected = [self expected:size];
  XCTAssertEqualObjects([result description], [expected description], @"Expected %@, got %@", expected, result);
}

- (void)testRotate180 {
  [self testRotate180:7 height:4];
  [self testRotate180:7 height:5];
  [self testRotate180:8 height:4];
  [self testRotate180:8 height:5];
}

- (void)testRotate180:(int)width height:(int)height {
  ZXBitMatrix *input = [self input:width height:height];
  [ZXPDF417Detector rotate180:input];
  ZXBitMatrix *expected = [self expected:width height:height];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      XCTAssertEqual([input getX:x y:y], [expected getX:x y:y], @"(%d,%d)", x, y);
    }
  }
}

- (ZXBitMatrix *)expected:(int)width height:(int)height {
  ZXBitMatrix *result = [[ZXBitMatrix alloc] initWithWidth:width height:height];
  for (int i = 0; i < BIT_MATRIX_POINTS_LEN; i += 2) {
    [result setX:width - 1 - BIT_MATRIX_POINTS[i] y:height - 1 - BIT_MATRIX_POINTS[i + 1]];
  }
  return result;
}

- (ZXBitMatrix *)input:(int)width height:(int)height {
  ZXBitMatrix *result = [[ZXBitMatrix alloc] initWithWidth:width height:height];
  for (int i = 0; i < BIT_MATRIX_POINTS_LEN; i += 2) {
    [result setX:BIT_MATRIX_POINTS[i] y:BIT_MATRIX_POINTS[i + 1]];
  }
  return result;
}

- (ZXBitArray *)expected:(int)size {
  ZXBitArray *expected = [[ZXBitArray alloc] initWithSize:size];
  for (int i = 0; i < BIT_SET_INDEX_LEN; i++) {
    int index = BIT_SET_INDEX[i];
    [expected set:size - 1 - index];
  }
  return expected;
}

- (ZXBitArray *)input:(int)size {
  ZXBitArray *input = [[ZXBitArray alloc] initWithSize:size];
  for (int i = 0; i < BIT_SET_INDEX_LEN; i++) {
    int index = BIT_SET_INDEX[i];
    [input set:index];
  }
  return input;
}

@end

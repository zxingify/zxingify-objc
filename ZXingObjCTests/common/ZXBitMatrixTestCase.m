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

#import "ZXBitMatrixTestCase.h"

@implementation ZXBitMatrixTestCase

static ZXIntArray *BIT_MATRIX_POINTS = nil;

+ (void)initialize {
  BIT_MATRIX_POINTS = [[ZXIntArray alloc] initWithInts:1, 2, 2, 0, 3, 1, -1];
}

- (void)testGetSet {
  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithDimension:33];
  XCTAssertEqual(33, matrix.height);
  for (int y = 0; y < 33; y++) {
    for (int x = 0; x < 33; x++) {
      if ((y * x % 3) == 0) {
        [matrix setX:x y:y];
      }
    }
  }
  for (int y = 0; y < 33; y++) {
    for (int x = 0; x < 33; x++) {
      XCTAssertEqual(y * x % 3 == 0, [matrix getX:x y:y]);
    }
  }
}

- (void)testSetRegion {
  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithDimension:5];
  [matrix setRegionAtLeft:1 top:1 width:3 height:3];
  for (int y = 0; y < 5; y++) {
    for (int x = 0; x < 5; x++) {
      XCTAssertEqual(y >= 1 && y <= 3 && x >= 1 && x <= 3, [matrix getX:x y:y]);
    }
  }
}

- (void)testRectangularMatrix {
  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithWidth:75 height:20];
  XCTAssertEqual(75, matrix.width);
  XCTAssertEqual(20, matrix.height);
  [matrix setX:10 y:0];
  [matrix setX:11 y:1];
  [matrix setX:50 y:2];
  [matrix setX:51 y:3];
  [matrix flipX:74 y:4];
  [matrix flipX:0 y:5];

  // Should all be on
  XCTAssertTrue([matrix getX:10 y:0]);
  XCTAssertTrue([matrix getX:11 y:1]);
  XCTAssertTrue([matrix getX:50 y:2]);
  XCTAssertTrue([matrix getX:51 y:3]);
  XCTAssertTrue([matrix getX:74 y:4]);
  XCTAssertTrue([matrix getX:0 y:5]);

  // Flip a couple back off
  [matrix flipX:50 y:2];
  [matrix flipX:51 y:3];
  XCTAssertFalse([matrix getX:50 y:2]);
  XCTAssertFalse([matrix getX:51 y:3]);
}

- (void)testRectangularSetRegion {
  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithWidth:320 height:240];
  XCTAssertEqual(320, matrix.width);
  XCTAssertEqual(240, matrix.height);
  [matrix setRegionAtLeft:105 top:22 width:80 height:12];

  // Only bits in the region should be on
  for (int y = 0; y < 240; y++) {
    for (int x = 0; x < 320; x++) {
      XCTAssertEqual(y >= 22 && y < 34 && x >= 105 && x < 185, [matrix getX:x y:y]);
    }
  }
}

- (void)testGetRow {
  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithWidth:102 height:5];
  for (int x = 0; x < 102; x++) {
    if ((x & 0x03) == 0) {
      [matrix setX:x y:2];
    }
  }

  // Should allocate
  ZXBitArray *array = [matrix rowAtY:2 row:nil];
  XCTAssertEqual(102, array.size);

  // Should reallocate
  ZXBitArray *array2 = [[ZXBitArray alloc] initWithSize:60];
  array2 = [matrix rowAtY:2 row:array2];
  XCTAssertEqual(102, array2.size);

  // Should use provided object, with original BitArray size
  ZXBitArray *array3 = [[ZXBitArray alloc] initWithSize:200];
  array3 = [matrix rowAtY:2 row:array3];
  XCTAssertEqual(200, array3.size);

  for (int x = 0; x < 102; x++) {
    BOOL on = (x & 0x03) == 0;
    XCTAssertEqual(on, [array get:x]);
    XCTAssertEqual(on, [array2 get:x]);
    XCTAssertEqual(on, [array3 get:x]);
  }
}

- (void)testRotate180Simple {
  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithWidth:3 height:3];
  [matrix setX:0 y:0];
  [matrix setX:0 y:1];
  [matrix setX:1 y:2];
  [matrix setX:2 y:1];

  [matrix rotate180];

  XCTAssertTrue([matrix getX:2 y:2]);
  XCTAssertTrue([matrix getX:2 y:1]);
  XCTAssertTrue([matrix getX:1 y:0]);
  XCTAssertTrue([matrix getX:0 y:1]);
}

- (void)testRotate180 {
  [self testRotate180Width:7 height:4];
  [self testRotate180Width:7 height:5];
  [self testRotate180Width:8 height:4];
  [self testRotate180Width:8 height:5];
}

- (void)testRotate180Width:(int)width height:(int)height {
  ZXBitMatrix *input = [self inputWithWidth:width height:height];
  [input rotate180];
  ZXBitMatrix *expected = [self expectedWithWidth:width height:height];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      XCTAssertEqual([expected getX:x y:y], [input getX:x y:y], @"(%d,%d)", x, y);
    }
  }
}

- (ZXBitMatrix *)expectedWithWidth:(int)width height:(int)height {
  ZXBitMatrix *result = [[ZXBitMatrix alloc] initWithWidth:width height:height];
  for (int i = 0; i < BIT_MATRIX_POINTS.length; i += 2) {
    [result setX:width - 1 - BIT_MATRIX_POINTS.array[i] y:height - 1 - BIT_MATRIX_POINTS.array[i + 1]];
  }
  return result;
}

- (ZXBitMatrix *)inputWithWidth:(int)width height:(int)height {
  ZXBitMatrix *result = [[ZXBitMatrix alloc] initWithWidth:width height:height];
  for (int i = 0; i < BIT_MATRIX_POINTS.length; i += 2) {
    [result setX:BIT_MATRIX_POINTS.array[i] y:BIT_MATRIX_POINTS.array[i + 1]];
  }
  return result;
}

@end

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

#import "ZXBitArray.h"
#import "ZXBitMatrix.h"
#import "ZXBitMatrixTestCase.h"

@implementation ZXBitMatrixTestCase

- (void)testGetSet {
  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithDimension:33];
  STAssertEquals(matrix.height, 33, @"Expected matrix height to be 33");
  for (int y = 0; y < 33; y++) {
    for (int x = 0; x < 33; x++) {
      if ((y * x % 3) == 0) {
        [matrix setX:x y:y];
      }
    }
  }
  for (int y = 0; y < 33; y++) {
    for (int x = 0; x < 33; x++) {
      STAssertEquals([matrix getX:x y:y], (BOOL)(y * x % 3 == 0), @"Expected matrix (%d,%d) to equal %d", x, y, y * x % 3 == 0);
    }
  }
}

- (void)testSetRegion {
  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithDimension:5];
  [matrix setRegionAtLeft:1 top:1 width:3 height:3];
  for (int y = 0; y < 5; y++) {
    for (int x = 0; x < 5; x++) {
      BOOL expected = y >= 1 && y <= 3 && x >= 1 && x <= 3;
      STAssertEquals([matrix getX:x y:y], expected, @"Expected (%d,%d) to be %d", x, y, expected);
    }
  }
}

- (void)testRectangularMatrix {
  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithWidth:75 height:20];
  STAssertEquals(matrix.width, 75, @"Expected matrix.width to be 75");
  STAssertEquals(matrix.height, 20, @"Expected matrix.height to be 20");
  [matrix setX:10 y:0];
  [matrix setX:11 y:1];
  [matrix setX:50 y:2];
  [matrix setX:51 y:3];
  [matrix flipX:74 y:4];
  [matrix flipX:0 y:5];

  // Should all be on
  STAssertTrue([matrix getX:10 y:0], @"Expected (10,0) to be on");
  STAssertTrue([matrix getX:11 y:1], @"Expected (11,1) to be on");
  STAssertTrue([matrix getX:50 y:2], @"Expected (50,2) to be on");
  STAssertTrue([matrix getX:51 y:3], @"Expected (51,3) to be on");
  STAssertTrue([matrix getX:74 y:4], @"Expected (74,4) to be on");
  STAssertTrue([matrix getX:0 y:5], @"Expected (0,5) to be on");

  // Flip a couple back off
  [matrix flipX:50 y:2];
  [matrix flipX:51 y:3];
  STAssertFalse([matrix getX:50 y:2], @"Expected (50,2) to be off");
  STAssertFalse([matrix getX:51 y:3], @"Expected (51,3) to be off");
}

- (void)testRectangularSetRegion {
  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithWidth:320 height:240];
  STAssertEquals(matrix.width, 320, @"Expected matrix.width to be 320");
  STAssertEquals(matrix.height, 240, @"Expected matrix.height to be 240");
  [matrix setRegionAtLeft:105 top:22 width:80 height:12];

  // Only bits in the region should be on
  for (int y = 0; y < 240; y++) {
    for (int x = 0; x < 320; x++) {
      BOOL expected = y >= 22 && y < 34 && x >= 105 && x < 185;
      STAssertEquals([matrix getX:x y:y], expected, @"Expected matrix (%d,%d) to equal %d", x, y, expected);
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
  STAssertEquals(array.size, 102, @"Expected array.size to equal 102");

  // Should reallocate
  ZXBitArray *array2 = [[ZXBitArray alloc] initWithSize:60];
  array2 = [matrix rowAtY:2 row:array2];
  STAssertEquals(array2.size, 102, @"Expected array2.size to equal 102");

  // Should use provided object, with original BitArray size
  ZXBitArray *array3 = [[ZXBitArray alloc] initWithSize:200];
  array3 = [matrix rowAtY:2 row:array3];
  STAssertEquals(array3.size, 200, @"Expected array3.size to equal 200");

  for (int x = 0; x < 102; x++) {
    BOOL on = (x & 0x03) == 0;
    STAssertEquals([array get:x], on, @"Expected [array get:%d] to be %d", x, on);
    STAssertEquals([array2 get:x], on, @"Expected [array2 get:%d] to be %d", x, on);
    STAssertEquals([array3 get:x], on, @"Expected [array3 get:%d] to be %d", x, on);
  }
}

@end

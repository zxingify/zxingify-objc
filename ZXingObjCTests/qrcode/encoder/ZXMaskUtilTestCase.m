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

#import "ZXMaskUtilTestCase.h"

@implementation ZXMaskUtilTestCase

- (void)testApplyMaskPenaltyRule1 {
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:4 height:1];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:2 y:0 intValue:0];
  [matrix setX:3 y:0 intValue:0];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule1:matrix], 0, @"Expected applyMaskPenaltyRule1 to return 0");
  // Horizontal.
  matrix = [[ZXByteMatrix alloc] initWithWidth:6 height:1];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:2 y:0 intValue:0];
  [matrix setX:3 y:0 intValue:0];
  [matrix setX:4 y:0 intValue:0];
  [matrix setX:5 y:0 intValue:1];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule1:matrix], 3, @"Expected applyMaskPenaltyRule1 to return 3");
  [matrix setX:5 y:0 intValue:0];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule1:matrix], 4, @"Expected applyMaskPenaltyRule1 to return 4");
  // Vertical.
  matrix = [[ZXByteMatrix alloc] initWithWidth:1 height:6];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:0 y:1 intValue:0];
  [matrix setX:0 y:2 intValue:0];
  [matrix setX:0 y:3 intValue:0];
  [matrix setX:0 y:4 intValue:0];
  [matrix setX:0 y:5 intValue:1];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule1:matrix], 3, @"Expected applyMaskPenaltyRule1 to return 3");
  [matrix setX:0 y:5 intValue:0];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule1:matrix], 4, @"Expected applyMaskPenaltyRule1 to return 4");
}

- (void)testApplyMaskPenaltyRule2 {
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:1 height:1];
  [matrix setX:0 y:0 intValue:0];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule2:matrix], 0, @"Expected applyMaskPenaltyRule2 to return 0");
  matrix = [[ZXByteMatrix alloc] initWithWidth:2 height:2];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:0 y:1 intValue:0];
  [matrix setX:1 y:1 intValue:1];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule2:matrix], 0, @"Expected applyMaskPenaltyRule2 to return 0");
  matrix = [[ZXByteMatrix alloc] initWithWidth:2 height:2];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:0 y:1 intValue:0];
  [matrix setX:1 y:1 intValue:0];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule2:matrix], 3, @"Expected applyMaskPenaltyRule2 to return 3");
  matrix = [[ZXByteMatrix alloc] initWithWidth:3 height:3];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:2 y:0 intValue:0];
  [matrix setX:0 y:1 intValue:0];
  [matrix setX:1 y:1 intValue:0];
  [matrix setX:2 y:1 intValue:0];
  [matrix setX:0 y:2 intValue:0];
  [matrix setX:1 y:2 intValue:0];
  [matrix setX:2 y:2 intValue:0];
  // Four instances of 2x2 blocks.
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule2:matrix], 3 * 4, @"Expected applyMaskPenaltyRule2 to return 3 * 4");
}

- (void)testApplyMaskPenaltyRule3 {
  // Horizontal 00001011101.
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:11 height:1];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:2 y:0 intValue:0];
  [matrix setX:3 y:0 intValue:0];
  [matrix setX:4 y:0 intValue:1];
  [matrix setX:5 y:0 intValue:0];
  [matrix setX:6 y:0 intValue:1];
  [matrix setX:7 y:0 intValue:1];
  [matrix setX:8 y:0 intValue:1];
  [matrix setX:9 y:0 intValue:0];
  [matrix setX:10 y:0 intValue:1];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule3:matrix], 40, @"Expected applyMaskPenaltyRule3 to return 40");
  // Horizontal 10111010000.
  matrix = [[ZXByteMatrix alloc] initWithWidth:11 height:1];
  [matrix setX:0 y:0 intValue:1];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:2 y:0 intValue:1];
  [matrix setX:3 y:0 intValue:1];
  [matrix setX:4 y:0 intValue:1];
  [matrix setX:5 y:0 intValue:0];
  [matrix setX:6 y:0 intValue:1];
  [matrix setX:7 y:0 intValue:0];
  [matrix setX:8 y:0 intValue:0];
  [matrix setX:9 y:0 intValue:0];
  [matrix setX:10 y:0 intValue:0];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule3:matrix], 40, @"Expected applyMaskPenaltyRule3 to return 40");
  // Vertical 00001011101.
  matrix = [[ZXByteMatrix alloc] initWithWidth:11 height:1];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:2 y:0 intValue:0];
  [matrix setX:3 y:0 intValue:0];
  [matrix setX:4 y:0 intValue:1];
  [matrix setX:5 y:0 intValue:0];
  [matrix setX:6 y:0 intValue:1];
  [matrix setX:7 y:0 intValue:1];
  [matrix setX:8 y:0 intValue:1];
  [matrix setX:9 y:0 intValue:0];
  [matrix setX:10 y:0 intValue:1];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule3:matrix], 40, @"Expected applyMaskPenaltyRule3 to return 40");
  // Vertical 10111010000.
  matrix = [[ZXByteMatrix alloc] initWithWidth:11 height:1];
  [matrix setX:0 y:0 intValue:1];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:2 y:0 intValue:1];
  [matrix setX:3 y:0 intValue:1];
  [matrix setX:4 y:0 intValue:1];
  [matrix setX:5 y:0 intValue:0];
  [matrix setX:6 y:0 intValue:1];
  [matrix setX:7 y:0 intValue:0];
  [matrix setX:8 y:0 intValue:0];
  [matrix setX:9 y:0 intValue:0];
  [matrix setX:10 y:0 intValue:0];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule3:matrix], 40, @"Expected applyMaskPenaltyRule3 to return 40");
}

- (void)testApplyMaskPenaltyRule4 {
  // Dark cell ratio = 0%
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:1 height:1];
  [matrix setX:0 y:0 intValue:0];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule4:matrix], 100, @"Expected applyMaskPenaltyRule4 to return 100");
  // Dark cell ratio = 5%
  matrix = [[ZXByteMatrix alloc] initWithWidth:2 height:1];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:0 y:0 intValue:1];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule4:matrix], 0, @"Expected applyMaskPenaltyRule4 to return 0");
  // Dark cell ratio = 66.67%
  matrix = [[ZXByteMatrix alloc] initWithWidth:6 height:1];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:1];
  [matrix setX:2 y:0 intValue:1];
  [matrix setX:3 y:0 intValue:1];
  [matrix setX:4 y:0 intValue:1];
  [matrix setX:5 y:0 intValue:0];
  XCTAssertEqual([ZXMaskUtil applyMaskPenaltyRule4:matrix], 30, @"Expected applyMaskPenaltyRule4 to return 30");
}

BOOL TestGetDataMaskBitInternal(int maskPattern, int *expected) {
  for (int x = 0; x < 6; ++x) {
    for (int y = 0; y < 6; ++y) {
      if ((expected[y*6+x] == 1) != [ZXMaskUtil dataMaskBit:maskPattern x:x y:y]) {
        return NO;
      }
    }
  }
  return YES;
}

// See mask patterns on the page 43 of JISX0510:2004.
- (void)testGetDataMaskBit {
  int mask0[6][6] = {
    {1, 0, 1, 0, 1, 0},
    {0, 1, 0, 1, 0, 1},
    {1, 0, 1, 0, 1, 0},
    {0, 1, 0, 1, 0, 1},
    {1, 0, 1, 0, 1, 0},
    {0, 1, 0, 1, 0, 1},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(0, (int *)mask0), @"Expected TestGetDataMaskBitInternal to return YES");
  int mask1[6][6] = {
    {1, 1, 1, 1, 1, 1},
    {0, 0, 0, 0, 0, 0},
    {1, 1, 1, 1, 1, 1},
    {0, 0, 0, 0, 0, 0},
    {1, 1, 1, 1, 1, 1},
    {0, 0, 0, 0, 0, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(1, (int *)mask1), @"Expected TestGetDataMaskBitInternal to return YES");
  int mask2[6][6] = {
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(2, (int *)mask2), @"Expected TestGetDataMaskBitInternal to return YES");
  int mask3[6][6] = {
    {1, 0, 0, 1, 0, 0},
    {0, 0, 1, 0, 0, 1},
    {0, 1, 0, 0, 1, 0},
    {1, 0, 0, 1, 0, 0},
    {0, 0, 1, 0, 0, 1},
    {0, 1, 0, 0, 1, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(3, (int *)mask3), @"Expected TestGetDataMaskBitInternal to return YES");
  int mask4[6][6] = {
    {1, 1, 1, 0, 0, 0},
    {1, 1, 1, 0, 0, 0},
    {0, 0, 0, 1, 1, 1},
    {0, 0, 0, 1, 1, 1},
    {1, 1, 1, 0, 0, 0},
    {1, 1, 1, 0, 0, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(4, (int *)mask4), @"Expected TestGetDataMaskBitInternal to return YES");
  int mask5[6][6] = {
    {1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 1, 0, 1, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 0, 0, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(5, (int *)mask5), @"Expected TestGetDataMaskBitInternal to return YES");
  int mask6[6][6] = {
    {1, 1, 1, 1, 1, 1},
    {1, 1, 1, 0, 0, 0},
    {1, 1, 0, 1, 1, 0},
    {1, 0, 1, 0, 1, 0},
    {1, 0, 1, 1, 0, 1},
    {1, 0, 0, 0, 1, 1},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(6, (int *)mask6), @"Expected TestGetDataMaskBitInternal to return YES");
  int mask7[6][6] = {
    {1, 0, 1, 0, 1, 0},
    {0, 0, 0, 1, 1, 1},
    {1, 0, 0, 0, 1, 1},
    {0, 1, 0, 1, 0, 1},
    {1, 1, 1, 0, 0, 0},
    {0, 1, 1, 1, 0, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(7, (int *)mask7), @"Expected TestGetDataMaskBitInternal to return YES");
}

@end

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

#import "ZXQRCodeMaskUtil.h"
#import "ZXQRCodeMaskUtilTestCase.h"

@implementation ZXQRCodeMaskUtilTestCase

- (void)testApplyMaskPenaltyRule1 {
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:4 height:1];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:2 y:0 intValue:0];
  [matrix setX:3 y:0 intValue:0];
  XCTAssertEqual(0, [ZXQRCodeMaskUtil applyMaskPenaltyRule1:matrix]);
  // Horizontal.
  matrix = [[ZXByteMatrix alloc] initWithWidth:6 height:1];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:2 y:0 intValue:0];
  [matrix setX:3 y:0 intValue:0];
  [matrix setX:4 y:0 intValue:0];
  [matrix setX:5 y:0 intValue:1];
  XCTAssertEqual(3, [ZXQRCodeMaskUtil applyMaskPenaltyRule1:matrix]);
  [matrix setX:5 y:0 intValue:0];
  XCTAssertEqual(4, [ZXQRCodeMaskUtil applyMaskPenaltyRule1:matrix]);
  // Vertical.
  matrix = [[ZXByteMatrix alloc] initWithWidth:1 height:6];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:0 y:1 intValue:0];
  [matrix setX:0 y:2 intValue:0];
  [matrix setX:0 y:3 intValue:0];
  [matrix setX:0 y:4 intValue:0];
  [matrix setX:0 y:5 intValue:1];
  XCTAssertEqual(3, [ZXQRCodeMaskUtil applyMaskPenaltyRule1:matrix]);
  [matrix setX:0 y:5 intValue:0];
  XCTAssertEqual(4, [ZXQRCodeMaskUtil applyMaskPenaltyRule1:matrix]);
}

- (void)testApplyMaskPenaltyRule2 {
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:1 height:1];
  [matrix setX:0 y:0 intValue:0];
  XCTAssertEqual(0, [ZXQRCodeMaskUtil applyMaskPenaltyRule2:matrix]);
  matrix = [[ZXByteMatrix alloc] initWithWidth:2 height:2];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:0 y:1 intValue:0];
  [matrix setX:1 y:1 intValue:1];
  XCTAssertEqual(0, [ZXQRCodeMaskUtil applyMaskPenaltyRule2:matrix]);
  matrix = [[ZXByteMatrix alloc] initWithWidth:2 height:2];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:0];
  [matrix setX:0 y:1 intValue:0];
  [matrix setX:1 y:1 intValue:0];
  XCTAssertEqual(3, [ZXQRCodeMaskUtil applyMaskPenaltyRule2:matrix]);
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
  XCTAssertEqual(3 * 4, [ZXQRCodeMaskUtil applyMaskPenaltyRule2:matrix]);
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
  XCTAssertEqual(40, [ZXQRCodeMaskUtil applyMaskPenaltyRule3:matrix]);
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
  XCTAssertEqual(40, [ZXQRCodeMaskUtil applyMaskPenaltyRule3:matrix]);
  // Vertical 00001011101.
  matrix = [[ZXByteMatrix alloc] initWithWidth:1 height:11];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:0 y:1 intValue:0];
  [matrix setX:0 y:2 intValue:0];
  [matrix setX:0 y:3 intValue:0];
  [matrix setX:0 y:4 intValue:1];
  [matrix setX:0 y:5 intValue:0];
  [matrix setX:0 y:6 intValue:1];
  [matrix setX:0 y:7 intValue:1];
  [matrix setX:0 y:8 intValue:1];
  [matrix setX:0 y:9 intValue:0];
  [matrix setX:0 y:10 intValue:1];
  XCTAssertEqual(40, [ZXQRCodeMaskUtil applyMaskPenaltyRule3:matrix]);
  // Vertical 10111010000.
  matrix = [[ZXByteMatrix alloc] initWithWidth:1 height:11];
  [matrix setX:0 y:0 intValue:1];
  [matrix setX:0 y:1 intValue:0];
  [matrix setX:0 y:2 intValue:1];
  [matrix setX:0 y:3 intValue:1];
  [matrix setX:0 y:4 intValue:1];
  [matrix setX:0 y:5 intValue:0];
  [matrix setX:0 y:6 intValue:1];
  [matrix setX:0 y:7 intValue:0];
  [matrix setX:0 y:8 intValue:0];
  [matrix setX:0 y:9 intValue:0];
  [matrix setX:0 y:10 intValue:0];
  XCTAssertEqual(40, [ZXQRCodeMaskUtil applyMaskPenaltyRule3:matrix]);
}

- (void)testApplyMaskPenaltyRule4 {
  // Dark cell ratio = 0%
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:1 height:1];
  [matrix setX:0 y:0 intValue:0];
  XCTAssertEqual(100, [ZXQRCodeMaskUtil applyMaskPenaltyRule4:matrix]);
  // Dark cell ratio = 5%
  matrix = [[ZXByteMatrix alloc] initWithWidth:2 height:1];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:0 y:0 intValue:1];
  XCTAssertEqual(0, [ZXQRCodeMaskUtil applyMaskPenaltyRule4:matrix]);
  // Dark cell ratio = 66.67%
  matrix = [[ZXByteMatrix alloc] initWithWidth:6 height:1];
  [matrix setX:0 y:0 intValue:0];
  [matrix setX:1 y:0 intValue:1];
  [matrix setX:2 y:0 intValue:1];
  [matrix setX:3 y:0 intValue:1];
  [matrix setX:4 y:0 intValue:1];
  [matrix setX:5 y:0 intValue:0];
  XCTAssertEqual(30, [ZXQRCodeMaskUtil applyMaskPenaltyRule4:matrix]);
}

BOOL TestGetDataMaskBitInternal(int maskPattern, const int expected[]) {
  for (int x = 0; x < 6; ++x) {
    for (int y = 0; y < 6; ++y) {
      if ((expected[y*6+x] == 1) != [ZXQRCodeMaskUtil dataMaskBit:maskPattern x:x y:y]) {
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
  XCTAssertTrue(TestGetDataMaskBitInternal(0, (const int *)mask0));
  int mask1[6][6] = {
    {1, 1, 1, 1, 1, 1},
    {0, 0, 0, 0, 0, 0},
    {1, 1, 1, 1, 1, 1},
    {0, 0, 0, 0, 0, 0},
    {1, 1, 1, 1, 1, 1},
    {0, 0, 0, 0, 0, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(1, (const int *)mask1));
  int mask2[6][6] = {
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(2, (const int *)mask2));
  int mask3[6][6] = {
    {1, 0, 0, 1, 0, 0},
    {0, 0, 1, 0, 0, 1},
    {0, 1, 0, 0, 1, 0},
    {1, 0, 0, 1, 0, 0},
    {0, 0, 1, 0, 0, 1},
    {0, 1, 0, 0, 1, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(3, (const int *)mask3));
  int mask4[6][6] = {
    {1, 1, 1, 0, 0, 0},
    {1, 1, 1, 0, 0, 0},
    {0, 0, 0, 1, 1, 1},
    {0, 0, 0, 1, 1, 1},
    {1, 1, 1, 0, 0, 0},
    {1, 1, 1, 0, 0, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(4, (const int *)mask4));
  int mask5[6][6] = {
    {1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 1, 0, 1, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 0, 0, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(5, (const int *)mask5));
  int mask6[6][6] = {
    {1, 1, 1, 1, 1, 1},
    {1, 1, 1, 0, 0, 0},
    {1, 1, 0, 1, 1, 0},
    {1, 0, 1, 0, 1, 0},
    {1, 0, 1, 1, 0, 1},
    {1, 0, 0, 0, 1, 1},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(6, (const int *)mask6));
  int mask7[6][6] = {
    {1, 0, 1, 0, 1, 0},
    {0, 0, 0, 1, 1, 1},
    {1, 0, 0, 0, 1, 1},
    {0, 1, 0, 1, 0, 1},
    {1, 1, 1, 0, 0, 0},
    {0, 1, 1, 1, 0, 0},
  };
  XCTAssertTrue(TestGetDataMaskBitInternal(7, (const int *)mask7));
}

@end

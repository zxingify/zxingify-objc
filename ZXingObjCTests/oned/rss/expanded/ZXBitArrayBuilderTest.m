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

#import "ZXBitArrayBuilder.h"
#import "ZXBitArrayBuilderTest.h"
#import "ZXRSSExpandedPair.h"

@implementation ZXBitArrayBuilderTest

- (void)testBuildBitArray1 {
  NSArray *pairValues = @[[[ZXIntArray alloc] initWithInts:19, -1], [[ZXIntArray alloc] initWithInts:673, 16, -1]];

  NSString *expected = @" .......X ..XX..X. X.X....X .......X ....";

  [self checkBinary:pairValues expected:expected];
}

- (void)checkBinary:(NSArray *)pairValues expected:(NSString *)expected {
  ZXBitArray *binary = [self buildBitArray:pairValues];
  XCTAssertEqualObjects(expected, [binary description]);
}

- (ZXBitArray *)buildBitArray:(NSArray *)pairValues {
  NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:2];
  for (int i = 0; i < [pairValues count]; ++i) {
    ZXIntArray *pair = pairValues[i];

    ZXRSSDataCharacter *leftChar;
    if (i == 0) {
      leftChar = nil;
    } else {
      leftChar = [[ZXRSSDataCharacter alloc] initWithValue:pair.array[0] checksumPortion:0];
    }

    ZXRSSDataCharacter *rightChar;
    if (i == 0) {
      rightChar = [[ZXRSSDataCharacter alloc] initWithValue:pair.array[0] checksumPortion:0];
    } else if (pair.length == 2) {
      rightChar = [[ZXRSSDataCharacter alloc] initWithValue:pair.array[1] checksumPortion:0];
    } else {
      rightChar = nil;
    }

    ZXRSSExpandedPair *expandedPair = [[ZXRSSExpandedPair alloc] initWithLeftChar:leftChar rightChar:rightChar finderPattern:nil mayBeLast:YES];
    [pairs addObject:expandedPair];
  }

  return [ZXBitArrayBuilder buildBitArray:pairs];
}

@end

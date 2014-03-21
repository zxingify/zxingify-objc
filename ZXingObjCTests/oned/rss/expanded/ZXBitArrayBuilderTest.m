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

#import "ZXBitArrayBuilderTest.h"

@implementation ZXBitArrayBuilderTest

- (void)testBuildBitArray1 {
  int lengths[2] = {1, 2};
  int pairValue1[1] = { 19 };
  int pairValue2[2] = { 673, 16 };

  int *pairValues[2];
  pairValues[0] = pairValue1;
  pairValues[1] = pairValue2;

  NSString *expected = @" .......X ..XX..X. X.X....X .......X ....";

  [self checkBinaryValues:pairValues pairValuesLen:2 lengths:lengths expected:expected];
}

- (void)checkBinaryValues:(int **)pairValues pairValuesLen:(int)pairValuesLen lengths:(int *)lengths expected:(NSString *)expected {
  ZXBitArray *binary = [self buildBitArrayPairValues:pairValues pairValuesLen:pairValuesLen lengths:lengths];
  XCTAssertEqualObjects([binary description], expected, @"Expected %@ to equal %@", [binary description], expected);
}

- (ZXBitArray *)buildBitArrayPairValues:(int **)pairValues pairValuesLen:(int)pairValuesLen lengths:(int *)lengths {
  NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:2];
  for (int i = 0; i < pairValuesLen; ++i) {
    int *pair = pairValues[i];

    ZXDataCharacter *leftChar;
    if (i == 0) {
      leftChar = nil;
    } else {
      leftChar = [[ZXDataCharacter alloc] initWithValue:pair[0] checksumPortion:0];
    }

    ZXDataCharacter *rightChar;
    if (i == 0) {
      rightChar = [[ZXDataCharacter alloc] initWithValue:pair[0] checksumPortion:0];
    } else if (lengths[i] == 2) {
      rightChar = [[ZXDataCharacter alloc] initWithValue:pair[1] checksumPortion:0];
    } else {
      rightChar = nil;
    }

    ZXExpandedPair *expandedPair = [[ZXExpandedPair alloc] initWithLeftChar:leftChar rightChar:rightChar finderPattern:nil mayBeLast:YES];
    [pairs addObject:expandedPair];
  }

  return [ZXBitArrayBuilder buildBitArray:pairs];
}

@end

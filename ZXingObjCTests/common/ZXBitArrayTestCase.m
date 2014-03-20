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

#import "ZXBitArrayTestCase.h"

@interface ZXBitArray (TestConstructor)

// For testing only
- (id)initWithBits:(ZXIntArray *)bits size:(int)size;

@end

@implementation ZXBitArrayTestCase

- (void)testGetSet {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:33];
  for (int i = 0; i < 33; i++) {
    XCTAssertFalse([array get:i], @"Expected [array get:%d] to be false", i);
    [array set:i];
    XCTAssertTrue([array get:i], @"Expected [array get:%d] to be true", i);
  }
}

- (void)testGetNextSet1 {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:32];
  for (int i = 0; i < array.size; i++) {
    XCTAssertEqual([array nextSet:i], 32, @"Expected [array nextSet:%d] to equal 32", i);
  }
  array = [[ZXBitArray alloc] initWithSize:33];
  for (int i = 0; i < array.size; i++) {
    XCTAssertEqual([array nextSet:i], 33, @"Expected [array nextSet:%d] to equal 33", i);
  }
}

- (void)testGetNextSet2 {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:33];
  [array set:31];
  for (int i = 0; i < array.size; i++) {
    int expected = i <= 31 ? 31 : 33;
    XCTAssertEqual([array nextSet:i], expected, @"Expected [array nextSet:%d] to equal %d", i, expected);
  }
  array = [[ZXBitArray alloc] initWithSize:33];
  [array set:32];
  for (int i = 0; i < array.size; i++) {
    XCTAssertEqual([array nextSet:i], 32, @"Expected [array nextSet:%d] to equal 32", i);
  }
}

- (void)testGetNextSet3 {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:63];
  [array set:31];
  [array set:32];
  for (int i = 0; i < array.size; i++) {
    int expected;
    if (i <= 31) {
      expected = 31;
    } else if (i == 32) {
      expected = 32;
    } else {
      expected = 63;
    }
    XCTAssertEqual([array nextSet:i], expected, @"Expected [array nextSet:%d] to equal %d", i, expected);
  }
}

- (void)testGetNextSet4 {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:63];
  [array set:33];
  [array set:40];
  for (int i = 0; i < array.size; i++) {
    int expected;
    if (i <= 33) {
      expected = 33;
    } else if (i <= 40) {
      expected = 40;
    } else {
      expected = 63;
    }
    XCTAssertEqual([array nextSet:i], expected, @"Expected [array nextSet:%d] to equal %d", i, expected);
  }
}

- (void)testGetNextSet5 {
  for (int i = 0; i < 10; i++) {
    ZXBitArray *array = [[ZXBitArray alloc] initWithSize:(arc4random() % 100) + 1];
    int numSet = arc4random() % 20;
    for (int j = 0; j < numSet; j++) {
      [array set:arc4random() % array.size];
    }
    int numQueries = arc4random() % 20;
    for (int j = 0; j < numQueries; j++) {
      int query = arc4random() % array.size;
      int expected = query;
      while (expected < array.size && ![array get:expected]) {
        expected++;
      }
      int actual = [array nextSet:query];
      if (actual != expected) {
        [array nextSet:query];
      }
      XCTAssertEqual(actual, expected, @"Expected %d to equal %d", actual, expected);
    }
  }
}

- (void)testSetBulk {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:64];
  [array setBulk:32 newBits:0xFFFF0000];
  for (int i = 0; i < 48; i++) {
    XCTAssertFalse([array get:i], @"Expected [array get:%d] to be false", i);
  }
  for (int i = 48; i < 64; i++) {
    XCTAssertTrue([array get:i], @"Expected [array get:%d] to be true", i);
  }
}

- (void)testClear {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:32];
  for (int i = 0; i < 32; i++) {
    [array set:i];
  }
  [array clear];
  for (int i = 0; i < 32; i++) {
    XCTAssertFalse([array get:i], @"Expected [array get:%d] to be false", i);
  }
}

- (void)testGetArray {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:64];
  [array set:0];
  [array set:63];
  int32_t *ints = array.bits;
  XCTAssertEqual(ints[0], 1, @"Expected ints[0] to equal 1");
  XCTAssertEqual(ints[1], INT_MIN, @"Expected ints[1] to equal INT_MIN");
}

- (void)testIsRange {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:64];
  XCTAssertTrue([array isRange:0 end:64 value:NO], @"Expected range 0-64 of NO to be true");
  XCTAssertFalse([array isRange:0 end:64 value:YES], @"Expected range 0-64 of YES to be false");
  [array set:32];
  XCTAssertTrue([array isRange:32 end:33 value:YES], @"Expected range 32-33 of YES to be true");
  [array set:31];
  XCTAssertTrue([array isRange:31 end:33 value:YES], @"Expected range 31-33 of YES to be true");
  [array set:34];
  XCTAssertFalse([array isRange:31 end:35 value:YES], @"Expected range 31-35 of YES to be false");
  for (int i = 0; i < 31; i++) {
    [array set:i];
  }
  XCTAssertTrue([array isRange:0 end:33 value:YES], @"Expected range 0-33 of YES to be true");
  for (int i = 33; i < 64; i++) {
    [array set:i];
  }
  XCTAssertTrue([array isRange:0 end:64 value:YES], @"Expected range 0-64 of YES to be true");
  XCTAssertFalse([array isRange:0 end:64 value:NO], @"Expected range 0-64 of YES to be false");
}

- (void)testReverseAlgorithm {
  ZXIntArray *oldBits = [[ZXIntArray alloc] initWithInts:128, 256, 512, 6453324, 50934953, -1];
  for (int size = 1; size < 160; size++) {
    ZXIntArray *newBitsOriginal = [self reverseOriginal:[oldBits copy] size:size];
    ZXBitArray *newBitArray = [[ZXBitArray alloc] initWithBits:[oldBits copy] size:size];
    [newBitArray reverse];
    ZXIntArray *newBitsNew = [newBitArray bitArray];
    XCTAssertTrue([self arraysAreEqual:newBitsOriginal right:newBitsNew size:size / 32 + 1], @"Arrays are not equal");
  }
}

- (ZXIntArray *)reverseOriginal:(ZXIntArray *)oldBits size:(int)size {
  ZXIntArray *newBits = [[ZXIntArray alloc] initWithLength:oldBits.length];
  for (int i = 0; i < size; i++) {
    if ([self bitSet:oldBits i:size - i - 1]) {
      newBits.array[i / 32] |= 1 << (i & 0x1F);
    }
  }
  return newBits;
}

- (BOOL)bitSet:(ZXIntArray *)bits i:(int)i {
  return (bits.array[i / 32] & (1 << (i & 0x1F))) != 0;
}

- (BOOL)arraysAreEqual:(ZXIntArray *)left right:(ZXIntArray *)right size:(int)size {
  for (int i = 0; i < size; i++) {
    if (left.array[i] != right.array[i]) {
      return false;
    }
  }
  return true;
}

@end

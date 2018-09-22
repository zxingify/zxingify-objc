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
    XCTAssertFalse([array get:i]);
    [array set:i];
    XCTAssertTrue([array get:i]);
  }
}

- (void)testGetNextSet1 {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:32];
  for (int i = 0; i < array.size; i++) {
    XCTAssertEqual(32, [array nextSet:i], @"%d", i);
  }
  array = [[ZXBitArray alloc] initWithSize:33];
  for (int i = 0; i < array.size; i++) {
    XCTAssertEqual(33, [array nextSet:i], @"%d", i);
  }
}

- (void)testGetNextSet2 {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:33];
  [array set:31];
  for (int i = 0; i < array.size; i++) {
    XCTAssertEqual(i <= 31 ? 31 : 33, [array nextSet:i], @"%d", i);
  }
  array = [[ZXBitArray alloc] initWithSize:33];
  [array set:32];
  for (int i = 0; i < array.size; i++) {
    XCTAssertEqual(32, [array nextSet:i], @"%d", i);
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
    XCTAssertEqual(expected, [array nextSet:i], @"%d", i);
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
    XCTAssertEqual(expected, [array nextSet:i], @"%d", i);
  }
}

- (void)testGetNextSet5 {
  for (int i = 0; i < 10; i++) {
    srand(0xDEADBEEF);
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
      XCTAssertEqual(expected, actual);
    }
  }
}

- (void)testSetBulk {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:64];
  [array setBulk:32 newBits:0xFFFF0000];
  for (int i = 0; i < 48; i++) {
    XCTAssertFalse([array get:i]);
  }
  for (int i = 48; i < 64; i++) {
    XCTAssertTrue([array get:i]);
  }
}

- (void)testSetRange {
    ZXBitArray *array = [[ZXBitArray alloc] initWithSize:64];
    [array setRange:28 end:36];
    XCTAssertFalse([array get:27]);
    for (int i = 28; i < 36; i++) {
        XCTAssertTrue([array get:i]);
    }
    XCTAssertFalse([array get:36]);
}

- (void)testClear {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:32];
  for (int i = 0; i < 32; i++) {
    [array set:i];
  }
  [array clear];
  for (int i = 0; i < 32; i++) {
    XCTAssertFalse([array get:i]);
  }
}

- (void)testFlip {
    ZXBitArray *array = [[ZXBitArray alloc] initWithSize:32];
    XCTAssertFalse([array get:5]);
    [array flip:5];
    XCTAssertTrue([array get:5]);
    [array flip:5];
    XCTAssertFalse([array get:5]);
}

- (void)testGetArray {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:64];
  [array set:0];
  [array set:63];
  int32_t *ints = array.bits;
  XCTAssertEqual(1, ints[0]);
  XCTAssertEqual(INT_MIN, ints[1]);
}

- (void)testIsRange {
  ZXBitArray *array = [[ZXBitArray alloc] initWithSize:64];
  XCTAssertTrue([array isRange:0 end:64 value:NO]);
  XCTAssertFalse([array isRange:0 end:64 value:YES]);
  [array set:32];
  XCTAssertTrue([array isRange:32 end:33 value:YES]);
  [array set:31];
  XCTAssertTrue([array isRange:31 end:33 value:YES]);
  [array set:34];
  XCTAssertFalse([array isRange:31 end:35 value:YES]);
  for (int i = 0; i < 31; i++) {
    [array set:i];
  }
  XCTAssertTrue([array isRange:0 end:33 value:YES]);
  for (int i = 33; i < 64; i++) {
    [array set:i];
  }
  XCTAssertTrue([array isRange:0 end:64 value:YES]);
  XCTAssertFalse([array isRange:0 end:64 value:NO]);
}

- (void)testReverseAlgorithm {
  ZXIntArray *oldBits = [[ZXIntArray alloc] initWithInts:128, 256, 512, 6453324, 50934953, -1];
  for (int size = 1; size < 160; size++) {
    ZXIntArray *newBitsOriginal = [self reverseOriginal:[oldBits copy] size:size];
    ZXBitArray *newBitArray = [[ZXBitArray alloc] initWithBits:[oldBits copy] size:size];
    [newBitArray reverse];
    ZXIntArray *newBitsNew = [newBitArray bitArray];
    XCTAssertTrue([self arraysAreEqual:newBitsOriginal right:newBitsNew size:size / 32 + 1]);
  }
}

- (void)testEquals {
    ZXBitArray *a = [[ZXBitArray alloc] initWithSize:32];
    ZXBitArray *b = [[ZXBitArray alloc] initWithSize:32];
    XCTAssertEqualObjects(a, b);
    XCTAssertEqual(a.hash, b.hash);
    
    XCTAssertNotEqualObjects(a, [[ZXBitArray alloc] initWithSize:31]);
  
    [a set:16];
    XCTAssertNotEqualObjects(a, b);
    XCTAssertNotEqual(a.hash, b.hash);
    
    [b set:16];
    XCTAssertEqualObjects(a, b);
    XCTAssertEqual(a.hash, b.hash);
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

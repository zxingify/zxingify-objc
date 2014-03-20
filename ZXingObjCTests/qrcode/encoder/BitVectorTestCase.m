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

#import "BitVectorTestCase.h"

@implementation BitVectorTestCase

- (unsigned long)unsignedInt:(ZXBitArray *)v index:(int)index {
  unsigned long result = 0L;
  for (int i = 0, offset = index << 3; i < 32; i++) {
    if ([v get:offset + i]) {
      result |= 1L << (31 - i);
    }
  }
  return result;
}

- (void)testAppendBit {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  XCTAssertEqual(v.sizeInBytes, 0, @"Expected sizeInBytes to be 0");
  // 1
  [v appendBit:YES];
  XCTAssertEqual(v.size, 1, @"Expected size to be 1");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0x80000000L, @"Expected unsigned int at index 0 to equal %ld", 0x80000000L);
  // 10
  [v appendBit:NO];
  XCTAssertEqual(v.size, 2, @"Expected size to be 2");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0x80000000L, @"Expected unsigned int at index 0 to equal %ld", 0x80000000L);
  // 101
  [v appendBit:YES];
  XCTAssertEqual(v.size, 3, @"Expected size to be 3");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0xa0000000L, @"Expected unsigned int at index 0 to equal %ld", 0xa0000000L);
  // 1010
  [v appendBit:NO];
  XCTAssertEqual(v.size, 4, @"Expected size to be 4");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0xa0000000L, @"Expected unsigned int at index 0 to equal %ld", 0xa0000000L);
  // 10101
  [v appendBit:YES];
  XCTAssertEqual(v.size, 5, @"Expected size to be 5");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0xa8000000L, @"Expected unsigned int at index 0 to equal %ld", 0xa8000000L);
  // 101010
  [v appendBit:NO];
  XCTAssertEqual(v.size, 6, @"Expected size to be 6");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0xa8000000L, @"Expected unsigned int at index 0 to equal %ld", 0xa8000000L);
  // 1010101
  [v appendBit:YES];
  XCTAssertEqual(v.size, 7, @"Expected size to be 7");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0xaa000000L, @"Expected unsigned int at index 0 to equal %ld", 0xaa000000L);
  // 10101010
  [v appendBit:NO];
  XCTAssertEqual(v.size, 8, @"Expected size to be 8");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0xaa000000L, @"Expected unsigned int at index 0 to equal %ld", 0xaa000000L);
  // 10101010 1
  [v appendBit:YES];
  XCTAssertEqual(v.size, 9, @"Expected size to be 9");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0xaa800000L, @"Expected unsigned int at index 0 to equal %ld", 0xaa800000L);
  // 10101010 10
  [v appendBit:NO];
  XCTAssertEqual(v.size, 10, @"Expected size to be 10");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0xaa800000L, @"Expected unsigned int at index 0 to equal %ld", 0xaa800000L);
}

- (void)testAppendBits {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  [v appendBits:0x1 numBits:1];
  XCTAssertEqual(v.size, 1, @"Expected size to be 1");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0x80000000L, @"Expected unsigned int at index 0 to equal %ld", 0x80000000L);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0xff numBits:8];
  XCTAssertEqual(v.size, 8, @"Expected size to be 8");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0xff000000L, @"Expected unsigned int at index 0 to equal %ld", 0xff000000L);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0xff7 numBits:12];
  XCTAssertEqual(v.size, 12, @"Expected size to be 12");
  XCTAssertEqual([self unsignedInt:v index:0], (unsigned long)0xff700000L, @"Expected unsigned int at index 0 to equal %ld", 0xff700000L);
}

- (void)testNumBytes {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  XCTAssertEqual(v.sizeInBytes, 0, @"Expected sizeInBytes to be 0");
  [v appendBit:NO];
  // 1 bit was added in the vector, so 1 byte should be consumed.
  XCTAssertEqual(v.sizeInBytes, 1, @"Expected sizeInBytes to be 1");
  [v appendBits:0 numBits:7];
  XCTAssertEqual(v.sizeInBytes, 1, @"Expected sizeInBytes to be 1");
  [v appendBits:0 numBits:8];
  XCTAssertEqual(v.sizeInBytes, 2, @"Expected sizeInBytes to be 2");
  [v appendBits:0 numBits:1];
  // We now have 17 bits, so 3 bytes should be consumed.
  XCTAssertEqual(v.sizeInBytes, 3, @"Expected sizeInBytes to be 3");
}

- (void)testAppendBitVector {
  ZXBitArray *v1 = [[ZXBitArray alloc] init];
  [v1 appendBits:0xbe numBits:8];
  ZXBitArray *v2 = [[ZXBitArray alloc] init];
  [v2 appendBits:0xef numBits:8];
  [v1 appendBitArray:v2];
  // beef = 1011 1110 1110 1111
  NSString *expected = @" X.XXXXX. XXX.XXXX";
  XCTAssertEqualObjects([v1 description], expected, @"Expected v1 to be %@", expected);
}

- (void)testXOR {
  ZXBitArray *v1 = [[ZXBitArray alloc] init];
  [v1 appendBits:0x5555aaaa numBits:32];
  ZXBitArray *v2 = [[ZXBitArray alloc] init];
  [v2 appendBits:0xaaaa5555 numBits:32];
  [v1 xor:v2];
  XCTAssertEqual([self unsignedInt:v1 index:0], (unsigned long)0xffffffffL,
                 @"Expected unsigned int at index 0 to equal %ld", 0xffffffffL);
}

- (void)testXOR2 {
  ZXBitArray *v1 = [[ZXBitArray alloc] init];
  [v1 appendBits:0x2a numBits:7];  // 010 1010
  ZXBitArray *v2 = [[ZXBitArray alloc] init];
  [v2 appendBits:0x55 numBits:7];  // 101 0101
  [v1 xor:v2];
  XCTAssertEqual([self unsignedInt:v1 index:0], (unsigned long)0xfe000000L,
                 @"Expected unsigned int at index 0 to equal %ld", 0xfe000000L); // 1111 1110
}

- (void)testAt {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  [v appendBits:0xdead numBits:16];  // 1101 1110 1010 1101
  XCTAssertTrue([v get:0], @"Expected value at 0 to be 1");
  XCTAssertTrue([v get:1], @"Expected value at 1 to be 1");
  XCTAssertFalse([v get:2], @"Expected value at 2 to be 0");
  XCTAssertTrue([v get:3], @"Expected value at 3 to be 1");

  XCTAssertTrue([v get:4], @"Expected value at 4 to be 1");
  XCTAssertTrue([v get:5], @"Expected value at 5 to be 1");
  XCTAssertTrue([v get:6], @"Expected value at 6 to be 1");
  XCTAssertFalse([v get:7], @"Expected value at 7 to be 0");

  XCTAssertTrue([v get:8], @"Expected value at 8 to be 1");
  XCTAssertFalse([v get:9], @"Expected value at 9 to be 0");
  XCTAssertTrue([v get:10], @"Expected value at 10 to be 1");
  XCTAssertFalse([v get:11], @"Expected value at 11 to be 0");

  XCTAssertTrue([v get:12], @"Expected value at 12 to be 1");
  XCTAssertTrue([v get:13], @"Expected value at 13 to be 1");
  XCTAssertFalse([v get:14], @"Expected value at 14 to be 0");
  XCTAssertTrue([v get:15], @"Expected value at 15 to be 1");
}

- (void)testToString {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  [v appendBits:0xdead numBits:16];  // 1101 1110 1010 1101
  NSString *expected = @" XX.XXXX. X.X.XX.X";
  XCTAssertEqualObjects([v description], expected, @"Expected v to be %@", expected);
}

@end

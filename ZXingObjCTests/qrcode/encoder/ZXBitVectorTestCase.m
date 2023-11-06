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

#import "ZXBitVectorTestCase.h"

@implementation ZXBitVectorTestCase

- (long)unsignedInt:(ZXBitArray *)v index:(int)index {
  unsigned long result = 0L;
  for (int i = 0, offset = index * 8; i < 32; i++) {
    if ([v get:offset + i]) {
      result |= 1L << (31 - i);
    }
  }
  return result;
}

- (void)testAppendBit {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  XCTAssertEqual(0, v.sizeInBytes);
  // 1
  [v appendBit:YES];
  XCTAssertEqual(1, v.size);
  XCTAssertEqual(0x80000000L, [self unsignedInt:v index:0]);
  // 10
  [v appendBit:NO];
  XCTAssertEqual(2, v.size);
  XCTAssertEqual(0x80000000L, [self unsignedInt:v index:0]);
  // 101
  [v appendBit:YES];
  XCTAssertEqual(3, v.size);
  XCTAssertEqual(0xa0000000L, [self unsignedInt:v index:0]);
  // 1010
  [v appendBit:NO];
  XCTAssertEqual(4, v.size);
  XCTAssertEqual(0xa0000000L, [self unsignedInt:v index:0]);
  // 10101
  [v appendBit:YES];
  XCTAssertEqual(5, v.size);
  XCTAssertEqual(0xa8000000L, [self unsignedInt:v index:0]);
  // 101010
  [v appendBit:NO];
  XCTAssertEqual(6, v.size);
  XCTAssertEqual(0xa8000000L, [self unsignedInt:v index:0]);
  // 1010101
  [v appendBit:YES];
  XCTAssertEqual(7, v.size);
  XCTAssertEqual(0xaa000000L, [self unsignedInt:v index:0]);
  // 10101010
  [v appendBit:NO];
  XCTAssertEqual(8, v.size);
  XCTAssertEqual(0xaa000000L, [self unsignedInt:v index:0]);
  // 10101010 1
  [v appendBit:YES];
  XCTAssertEqual(9, v.size);
  XCTAssertEqual(0xaa800000L, [self unsignedInt:v index:0]);
  // 10101010 10
  [v appendBit:NO];
  XCTAssertEqual(10, v.size);
  XCTAssertEqual(0xaa800000L, [self unsignedInt:v index:0]);
}

- (void)testAppendBits {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  [v appendBits:0x1 numBits:1];
  XCTAssertEqual(1, v.size);
  XCTAssertEqual(0x80000000L, [self unsignedInt:v index:0]);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0xff numBits:8];
  XCTAssertEqual(8, v.size);
  XCTAssertEqual(0xff000000L, [self unsignedInt:v index:0]);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0xff7 numBits:12];
  XCTAssertEqual(12, v.size);
  XCTAssertEqual(0xff700000L, [self unsignedInt:v index:0]);
}

- (void)testNumBytes {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  XCTAssertEqual(0, v.sizeInBytes);
  [v appendBit:NO];
  // 1 bit was added in the vector, so 1 byte should be consumed.
  XCTAssertEqual(1, v.sizeInBytes);
  [v appendBits:0 numBits:7];
  XCTAssertEqual(1, v.sizeInBytes);
  [v appendBits:0 numBits:8];
  XCTAssertEqual(2, v.sizeInBytes);
  [v appendBits:0 numBits:1];
  // We now have 17 bits, so 3 bytes should be consumed.
  XCTAssertEqual(3, v.sizeInBytes);
}

- (void)testAppendBitVector {
  ZXBitArray *v1 = [[ZXBitArray alloc] init];
  [v1 appendBits:0xbe numBits:8];
  ZXBitArray *v2 = [[ZXBitArray alloc] init];
  [v2 appendBits:0xef numBits:8];
  [v1 appendBitArray:v2];
  // beef = 1011 1110 1110 1111
  XCTAssertEqualObjects(@" X.XXXXX. XXX.XXXX", [v1 description]);
}

- (void)testXOR {
  ZXBitArray *v1 = [[ZXBitArray alloc] init];
  [v1 appendBits:0x5555aaaa numBits:32];
  ZXBitArray *v2 = [[ZXBitArray alloc] init];
  [v2 appendBits:0xaaaa5555 numBits:32];
  [v1 xor:v2];
  XCTAssertEqual(0xffffffffL, [self unsignedInt:v1 index:0]);
}

- (void)testXOR2 {
  ZXBitArray *v1 = [[ZXBitArray alloc] init];
  [v1 appendBits:0x2a numBits:7];  // 010 1010
  ZXBitArray *v2 = [[ZXBitArray alloc] init];
  [v2 appendBits:0x55 numBits:7];  // 101 0101
  [v1 xor:v2];
  XCTAssertEqual(0xfe000000L, [self unsignedInt:v1 index:0]);
}

- (void)testAt {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  [v appendBits:0xdead numBits:16];  // 1101 1110 1010 1101
  XCTAssertTrue([v get:0]);
  XCTAssertTrue([v get:1]);
  XCTAssertFalse([v get:2]);
  XCTAssertTrue([v get:3]);

  XCTAssertTrue([v get:4]);
  XCTAssertTrue([v get:5]);
  XCTAssertTrue([v get:6]);
  XCTAssertFalse([v get:7]);

  XCTAssertTrue([v get:8]);
  XCTAssertFalse([v get:9]);
  XCTAssertTrue([v get:10]);
  XCTAssertFalse([v get:11]);

  XCTAssertTrue([v get:12]);
  XCTAssertTrue([v get:13]);
  XCTAssertFalse([v get:14]);
  XCTAssertTrue([v get:15]);
}

- (void)testToString {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  [v appendBits:0xdead numBits:16];  // 1101 1110 1010 1101
  XCTAssertEqualObjects(@" XX.XXXX. X.X.XX.X", [v description]);
}

@end

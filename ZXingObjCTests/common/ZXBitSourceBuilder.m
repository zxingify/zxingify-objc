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

#import "ZXBitSourceBuilder.h"

@interface ZXBitSourceBuilder ()

@property (nonatomic, assign) int bitsLeftInNextByte;
@property (nonatomic, assign) int8_t nextByte;
@property (nonatomic, strong) NSMutableData *output;

@end

@implementation ZXBitSourceBuilder

- (id)init {
  if (self = [super init]) {
    _output = [NSMutableData data];
    _nextByte = 0;
    _bitsLeftInNextByte = 8;
  }

  return self;
}

- (void)write:(int)value numBits:(int)numBits {
  if (numBits <= self.bitsLeftInNextByte) {
    self.nextByte <<= numBits;
    self.nextByte |= value;
    self.bitsLeftInNextByte -= numBits;
    if (self.bitsLeftInNextByte == 0) {
      [self.output appendBytes:&_nextByte length:1];
      self.nextByte = 0;
      self.bitsLeftInNextByte = 8;
    }
  } else {
    int bitsToWriteNow = self.bitsLeftInNextByte;
    int numRestOfBits = numBits - bitsToWriteNow;
    int mask = 0xFF >> (8 - bitsToWriteNow);
    int valueToWriteNow = (int)(((unsigned int)value) >> numRestOfBits) & mask;
    [self write:valueToWriteNow numBits:bitsToWriteNow];
    [self write:value numBits:numRestOfBits];
  }
}

- (ZXByteArray *)toByteArray {
  if (self.bitsLeftInNextByte < 8) {
    [self write:0 numBits:self.bitsLeftInNextByte];
  }
  ZXByteArray *bytes = [[ZXByteArray alloc] initWithLength:(unsigned int)[self.output length]];
  memcpy(bytes.array, [self.output bytes], bytes.length * sizeof(int8_t));
  return bytes;
}

@end

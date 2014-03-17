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
#import "ZXByteArray.h"

@interface ZXBitArray ()

@property (nonatomic, assign) int32_t *bits;
@property (nonatomic, assign) int bitsLength;
@property (nonatomic, assign) int size;

@end

@implementation ZXBitArray

- (id)init {
  if (self = [super init]) {
    _size = 0;
    _bits = (int32_t *)malloc(1 * sizeof(int32_t));
    _bitsLength = 1;
    _bits[0] = 0;
  }

  return self;
}

- (id)initWithSize:(int)size {
  if (self = [super init]) {
    _size = size;
    _bitsLength = (size + 31) >> 5;

    _bits = (int32_t *)malloc(_bitsLength * sizeof(int32_t));
    memset(_bits, 0, _bitsLength * sizeof(int32_t));
  }

  return self;
}


- (void)dealloc {
  if (_bits != NULL) {
    free(_bits);
    _bits = NULL;
  }
}

- (int)sizeInBytes {
  return (self.size + 7) >> 3;
}

- (void)ensureCapacity:(int)size {
  if (size > self.bitsLength << 5) {
    int newBitsLength = (size + 31) >> 5;
    self.bits = realloc(self.bits, newBitsLength * sizeof(int32_t));
    memset(self.bits + self.bitsLength, 0, (newBitsLength - self.bitsLength) * sizeof(int32_t));

    self.bitsLength = newBitsLength;
  }
}

- (BOOL)get:(int)i {
  return (self.bits[i >> 5] & (1 << (i & 0x1F))) != 0;
}

- (void)set:(int)i {
  self.bits[i >> 5] |= 1 << (i & 0x1F);
}

- (void)flip:(int)i {
  self.bits[i >> 5] ^= 1 << (i & 0x1F);
}

- (int)nextSet:(int)from {
  if (from >= self.size) {
    return self.size;
  }
  int bitsOffset = from >> 5;
  int32_t currentBits = self.bits[bitsOffset];
  // mask off lesser bits first
  currentBits &= ~((1 << (from & 0x1F)) - 1);
  while (currentBits == 0) {
    if (++bitsOffset == self.bitsLength) {
      return self.size;
    }
    currentBits = self.bits[bitsOffset];
  }
  int result = (bitsOffset << 5) + [self numberOfTrailingZeros:currentBits];
  return result > self.size ? self.size : result;
}

- (int)nextUnset:(int)from {
  if (from >= self.size) {
    return self.size;
  }
  int bitsOffset = from >> 5;
  int32_t currentBits = ~self.bits[bitsOffset];
  // mask off lesser bits first
  currentBits &= ~((1 << (from & 0x1F)) - 1);
  while (currentBits == 0) {
    if (++bitsOffset == self.bitsLength) {
      return self.size;
    }
    currentBits = ~self.bits[bitsOffset];
  }
  int result = (bitsOffset << 5) + [self numberOfTrailingZeros:currentBits];
  return result > self.size ? self.size : result;
}

- (void)setBulk:(int)i newBits:(int32_t)newBits {
  self.bits[i >> 5] = newBits;
}

- (void)setRange:(int)start end:(int)end {
  if (end < start) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Start greater than end" userInfo:nil];
  }
  if (end == start) {
    return;
  }
  end--; // will be easier to treat this as the last actually set bit -- inclusive
  int firstInt = start >> 5;
  int lastInt = end >> 5;
  for (int i = firstInt; i <= lastInt; i++) {
    int firstBit = i > firstInt ? 0 : start & 0x1F;
    int lastBit = i < lastInt ? 31 : end & 0x1F;
    int32_t mask;
    if (firstBit == 0 && lastBit == 31) {
      mask = -1;
    } else {
      mask = 0;
      for (int j = firstBit; j <= lastBit; j++) {
        mask |= 1 << j;
      }
    }
    self.bits[i] |= mask;
  }
}

- (void)clear {
  memset(self.bits, 0, self.bitsLength * sizeof(int32_t));
}

- (BOOL)isRange:(int)start end:(int)end value:(BOOL)value {
  if (end < start) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Start greater than end" userInfo:nil];
  }
  if (end == start) {
    return YES; // empty range matches
  }
  end--; // will be easier to treat this as the last actually set bit -- inclusive
  int firstInt = start >> 5;
  int lastInt = end >> 5;
  for (int i = firstInt; i <= lastInt; i++) {
    int firstBit = i > firstInt ? 0 : start & 0x1F;
    int lastBit = i < lastInt ? 31 : end & 0x1F;
    int32_t mask;
    if (firstBit == 0 && lastBit == 31) {
      mask = -1;
    } else {
      mask = 0;
      for (int j = firstBit; j <= lastBit; j++) {
        mask |= 1 << j;
      }
    }

    // Return false if we're looking for 1s and the masked bits[i] isn't all 1s (that is,
    // equals the mask, or we're looking for 0s and the masked portion is not all 0s
    if ((self.bits[i] & mask) != (value ? mask : 0)) {
      return NO;
    }
  }

  return YES;
}

- (void)appendBit:(BOOL)bit {
  [self ensureCapacity:self.size + 1];
  if (bit) {
    self.bits[self.size >> 5] |= 1 << (self.size & 0x1F);
  }
  self.size++;
}

- (void)appendBits:(int32_t)value numBits:(int)numBits {
  if (numBits < 0 || numBits > 32) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Num bits must be between 0 and 32"
                                 userInfo:nil];
  }
  [self ensureCapacity:self.size + numBits];
  for (int numBitsLeft = numBits; numBitsLeft > 0; numBitsLeft--) {
    [self appendBit:((value >> (numBitsLeft - 1)) & 0x01) == 1];
  }
}

- (void)appendBitArray:(ZXBitArray *)other {
  int otherSize = [other size];
  [self ensureCapacity:self.size + otherSize];

  for (int i = 0; i < otherSize; i++) {
    [self appendBit:[other get:i]];
  }
}

- (void)xor:(ZXBitArray *)other {
  if (self.bitsLength != other.bitsLength) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Sizes don't match"
                                 userInfo:nil];
  }

  for (int i = 0; i < self.bitsLength; i++) {
    // The last byte could be incomplete (i.e. not have 8 bits in
    // it) but there is no problem since 0 XOR 0 == 0.
    self.bits[i] ^= other.bits[i];
  }
}

- (void)toBytes:(int)bitOffset array:(ZXByteArray *)array offset:(int)offset numBytes:(int)numBytes {
  for (int i = 0; i < numBytes; i++) {
    int32_t theByte = 0;
    for (int j = 0; j < 8; j++) {
      if ([self get:bitOffset]) {
        theByte |= 1 << (7 - j);
      }
      bitOffset++;
    }
    array.array[offset + i] = (int8_t) theByte;
  }
}

- (void)reverse {
  int32_t *newBits = (int32_t *)malloc(self.size * sizeof(int32_t));
  memset(newBits, 0, self.size * sizeof(int32_t));
  for (int i = 0; i < self.size; i++) {
    if ([self get:self.size - i - 1]) {
      newBits[i >> 5] |= 1 << (i & 0x1F);
    }
  }

  if (self.bits != NULL) {
    free(self.bits);
  }
  self.bits = newBits;
}

- (NSString *)description {
  NSMutableString *result = [NSMutableString string];

  for (int i = 0; i < self.size; i++) {
    if ((i & 0x07) == 0) {
      [result appendString:@" "];
    }
    [result appendString:[self get:i] ? @"X" : @"."];
  }

  return result;
}

// Ported from OpenJDK Integer.numberOfTrailingZeros implementation
- (int32_t)numberOfTrailingZeros:(int32_t)i {
  int32_t y;
  if (i == 0) return 32;
  int32_t n = 31;
  y = i <<16; if (y != 0) { n = n -16; i = y; }
  y = i << 8; if (y != 0) { n = n - 8; i = y; }
  y = i << 4; if (y != 0) { n = n - 4; i = y; }
  y = i << 2; if (y != 0) { n = n - 2; i = y; }
  return n - (int32_t)((uint32_t)(i << 1) >> 31);
}

@end

/*
 * Copyright 2014 ZXing authors
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

#import "ZXBinaryShiftToken.h"
#import "ZXBitArray.h"

@interface ZXBinaryShiftToken ()

@property (nonatomic, assign, readonly) int16_t binaryShiftStart;
@property (nonatomic, assign, readonly) int16_t binaryShiftByteCount;

@end

@implementation ZXBinaryShiftToken

- (id)initWithPrevious:(ZXToken *)previous totalBitCount:(int)totalBitCount
      binaryShiftStart:(int)binaryShiftStart binaryShiftByteCount:(int)binaryShiftByteCount {
  if (self = [super initWithPrevious:previous totalBitCount:totalBitCount]) {
    _binaryShiftStart = (int16_t)binaryShiftStart;
    _binaryShiftByteCount = (int16_t)binaryShiftByteCount;
  }

  return self;
}

- (void)appendTo:(ZXBitArray *)bitArray text:(const int8_t *)text length:(NSUInteger)length {
  for (int i = 0; i < self.binaryShiftByteCount; i++) {
    if (i == 0 || (i == 31 && self.binaryShiftByteCount <= 62))  {
      // We need a header before the first character, and before
      // character 31 when the total byte code is <= 62
      [bitArray appendBits:31 numBits:5];
      if (self.binaryShiftByteCount > 62) {
        [bitArray appendBits:self.binaryShiftByteCount - 31 numBits:16];
      } else if (i == 0) {
        // 1 <= binaryShiftByteCode <= 62
        [bitArray appendBits:MIN(self.binaryShiftByteCount, 31) numBits:5];
      } else {
        // 32 <= binaryShiftCount <= 62 and i == 31
        [bitArray appendBits:self.binaryShiftByteCount - 31 numBits:5];
      }
    }
    [bitArray appendBits:text[self.binaryShiftStart + i] numBits:8];
  }
}

@end

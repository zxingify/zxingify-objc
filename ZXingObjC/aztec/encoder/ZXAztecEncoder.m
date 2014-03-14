/*
 * Copyright 2013 ZXing authors
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

#import "ZXAztecCode.h"
#import "ZXAztecEncoder.h"
#import "ZXAztecHighLevelEncoder.h"
#import "ZXBitArray.h"
#import "ZXBitMatrix.h"
#import "ZXGenericGF.h"
#import "ZXReedSolomonEncoder.h"

int ZX_DEFAULT_AZTEC_EC_PERCENT = 33;

const int NB_BITS_LEN = 33;
static int NB_BITS[NB_BITS_LEN]; // total bits per compact symbol for a given number of layers

const int NB_BITS_COMPACT_LEN = 5;
static int NB_BITS_COMPACT[NB_BITS_COMPACT_LEN]; // total bits per full symbol for a given number of layers

static int WORD_SIZE[33] = {
  4, 6, 6, 8, 8, 8, 8, 8, 8, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
  12, 12, 12, 12, 12, 12, 12, 12, 12, 12
};

@implementation ZXAztecEncoder

+ (void)initialize {
  for (int i = 1; i < NB_BITS_COMPACT_LEN; i++) {
    NB_BITS_COMPACT[i] = (88 + 16 * i) * i;
  }
  for (int i = 1; i < NB_BITS_LEN; i++) {
    NB_BITS[i] = (112 + 16 * i) * i;
  }
}

/**
 * Encodes the given binary content as an Aztec symbol
 */
+ (ZXAztecCode *)encode:(const int8_t *)data len:(NSUInteger)len {
  return [self encode:data len:len minECCPercent:ZX_DEFAULT_AZTEC_EC_PERCENT];
}

/**
 * Encodes the given binary content as an Aztec symbol
 */
+ (ZXAztecCode *)encode:(const int8_t *)data len:(NSUInteger)len minECCPercent:(int)minECCPercent {
  // High-level encode
  ZXBitArray *bits = [[[ZXAztecHighLevelEncoder alloc] initWithData:data textLength:len] encode];

  // stuff bits and choose symbol size
  int eccBits = bits.size * minECCPercent / 100 + 11;
  int totalSizeBits = bits.size + eccBits;
  int layers;
  int wordSize = 0;
  int totalSymbolBits = 0;
  ZXBitArray *stuffedBits = nil;
  for (layers = 1; layers < NB_BITS_COMPACT_LEN; layers++) {
    if (NB_BITS_COMPACT[layers] >= totalSizeBits) {
      if (wordSize != WORD_SIZE[layers]) {
        wordSize = WORD_SIZE[layers];
        stuffedBits = [self stuffBits:bits wordSize:wordSize];
      }
      totalSymbolBits = NB_BITS_COMPACT[layers];
      if (stuffedBits.size + eccBits <= NB_BITS_COMPACT[layers]) {
        break;
      }
    }
  }
  BOOL compact = YES;
  if (layers == NB_BITS_COMPACT_LEN) {
    compact = false;
    for (layers = 1; layers < NB_BITS_LEN; layers++) {
      if (NB_BITS[layers] >= totalSizeBits) {
        if (wordSize != WORD_SIZE[layers]) {
          wordSize = WORD_SIZE[layers];
          stuffedBits = [self stuffBits:bits wordSize:wordSize];
        }
        totalSymbolBits = NB_BITS[layers];
        if (stuffedBits.size + eccBits <= NB_BITS[layers]) {
          break;
        }
      }
    }
  }
  if (layers == NB_BITS_LEN || wordSize == 0) {
    [NSException raise:NSInvalidArgumentException format:@"Data too large for an Aztec code"];
  }

  // pad the end
  int messageSizeInWords = (stuffedBits.size + wordSize - 1) / wordSize;
  for (int i = messageSizeInWords * wordSize - stuffedBits.size; i > 0; i--) {
    [stuffedBits appendBit:YES];
  }

  // generate check words
  ZXReedSolomonEncoder *rs = [[ZXReedSolomonEncoder alloc] initWithField:[self getGF:wordSize]];
  int totalSizeInFullWords = totalSymbolBits / wordSize;

  int messageWords[totalSizeInFullWords];
  memset(messageWords, 0, totalSizeInFullWords * sizeof(int));
  [self bitsToWords:stuffedBits wordSize:wordSize totalWords:totalSizeInFullWords message:messageWords];
  [rs encode:messageWords toEncodeLen:totalSizeInFullWords ecBytes:totalSizeInFullWords - messageSizeInWords];

  // convert to bit array and pad in the beginning
  int startPad = totalSymbolBits % wordSize;
  ZXBitArray *messageBits = [[ZXBitArray alloc] init];
  [messageBits appendBits:0 numBits:startPad];
  for (int i = 0; i < totalSizeInFullWords; i++) {
    [messageBits appendBits:messageWords[i] numBits:wordSize];
  }

  // generate mode message
  ZXBitArray *modeMessage = [self generateModeMessageCompact:compact layers:layers messageSizeInWords:messageSizeInWords];

  // allocate symbol
  int baseMatrixSize = compact ? 11 + layers * 4 : 14 + layers * 4; // not including alignment lines
  int alignmentMap[baseMatrixSize];
  int matrixSize;
  if (compact) {
    // no alignment marks in compact mode, alignmentMap is a no-op
    matrixSize = baseMatrixSize;
    for (int i = 0; i < baseMatrixSize; i++) {
      alignmentMap[i] = i;
    }
  } else {
    matrixSize = baseMatrixSize + 1 + 2 * ((baseMatrixSize / 2 - 1) / 15);
    int origCenter = baseMatrixSize / 2;
    int center = matrixSize / 2;
    for (int i = 0; i < origCenter; i++) {
      int newOffset = i + i / 15;
      alignmentMap[origCenter - i - 1] = center - newOffset - 1;
      alignmentMap[origCenter + i] = center + newOffset + 1;
    }
  }
  ZXBitMatrix *matrix = [[ZXBitMatrix alloc] initWithDimension:matrixSize];

  // draw mode and data bits
  for (int i = 0, rowOffset = 0; i < layers; i++) {
    int rowSize = compact ? (layers - i) * 4 + 9 : (layers - i) * 4 + 12;
    for (int j = 0; j < rowSize; j++) {
      int columnOffset = j * 2;
      for (int k = 0; k < 2; k++) {
        if ([messageBits get:rowOffset + columnOffset + k]) {
          [matrix setX:alignmentMap[i * 2 + k] y:alignmentMap[i * 2 + j]];
        }
        if ([messageBits get:rowOffset + rowSize * 2 + columnOffset + k]) {
          [matrix setX:alignmentMap[i * 2 + j] y:alignmentMap[baseMatrixSize - 1 - i * 2 - k]];
        }
        if ([messageBits get:rowOffset + rowSize * 4 + columnOffset + k]) {
          [matrix setX:alignmentMap[baseMatrixSize - 1 - i * 2 - k] y:alignmentMap[baseMatrixSize - 1 - i * 2 - j]];
        }
        if ([messageBits get:rowOffset + rowSize * 6 + columnOffset + k]) {
          [matrix setX:alignmentMap[baseMatrixSize - 1 - i * 2 - j] y:alignmentMap[i * 2 + k]];
        }
      }
    }
    rowOffset += rowSize * 8;
  }
  [self drawModeMessage:matrix compact:compact matrixSize:matrixSize modeMessage:modeMessage];

  // draw alignment marks
  if (compact) {
    [self drawBullsEye:matrix center:matrixSize / 2 size:5];
  } else {
    [self drawBullsEye:matrix center:matrixSize / 2 size:7];
    for (int i = 0, j = 0; i < baseMatrixSize / 2 - 1; i += 15, j += 16) {
      for (int k = (matrixSize / 2) & 1; k < matrixSize; k += 2) {
        [matrix setX:matrixSize / 2 - j y:k];
        [matrix setX:matrixSize / 2 + j y:k];
        [matrix setX:k y:matrixSize / 2 - j];
        [matrix setX:k y:matrixSize / 2 + j];
      }
    }
  }

  ZXAztecCode *aztec = [[ZXAztecCode alloc] init];
  aztec.compact = compact;
  aztec.size = matrixSize;
  aztec.layers = layers;
  aztec.codeWords = messageSizeInWords;
  aztec.matrix = matrix;
  return aztec;
}

+ (void)drawBullsEye:(ZXBitMatrix *)matrix center:(int)center size:(int)size {
  for (int i = 0; i < size; i += 2) {
    for (int j = center - i; j <= center + i; j++) {
      [matrix setX:j y:center - i];
      [matrix setX:j y:center + i];
      [matrix setX:center - i y:j];
      [matrix setX:center + i y:j];
    }
  }
  [matrix setX:center - size y:center - size];
  [matrix setX:center - size + 1 y:center - size];
  [matrix setX:center - size y:center - size + 1];
  [matrix setX:center + size y:center - size];
  [matrix setX:center + size y:center - size + 1];
  [matrix setX:center + size y:center + size - 1];
}

+ (ZXBitArray *)generateModeMessageCompact:(BOOL)compact layers:(int)layers messageSizeInWords:(int)messageSizeInWords {
  ZXBitArray *modeMessage = [[ZXBitArray alloc] init];
  if (compact) {
    [modeMessage appendBits:layers - 1 numBits:2];
    [modeMessage appendBits:messageSizeInWords - 1 numBits:6];
    modeMessage = [self generateCheckWords:modeMessage totalSymbolBits:28 wordSize:4];
  } else {
    [modeMessage appendBits:layers - 1 numBits:5];
    [modeMessage appendBits:messageSizeInWords - 1 numBits:11];
    modeMessage = [self generateCheckWords:modeMessage totalSymbolBits:40 wordSize:4];
  }
  return modeMessage;
}

+ (void)drawModeMessage:(ZXBitMatrix *)matrix compact:(BOOL)compact matrixSize:(int)matrixSize modeMessage:(ZXBitArray *)modeMessage {
  if (compact) {
    for (int i = 0; i < 7; i++) {
      if ([modeMessage get:i]) {
        [matrix setX:matrixSize / 2 - 3 + i y:matrixSize / 2 - 5];
      }
      if ([modeMessage get:i + 7]) {
        [matrix setX:matrixSize / 2 + 5 y:matrixSize / 2 - 3 + i];
      }
      if ([modeMessage get:20 - i]) {
        [matrix setX:matrixSize / 2 - 3 + i y:matrixSize / 2 + 5];
      }
      if ([modeMessage get:27 - i]) {
        [matrix setX:matrixSize / 2 - 5 y:matrixSize / 2 - 3 + i];
      }
    }
  } else {
    for (int i = 0; i < 10; i++) {
      if ([modeMessage get:i]) {
        [matrix setX:matrixSize / 2 - 5 + i + i / 5 y:matrixSize / 2 - 7];
      }
      if ([modeMessage get:i + 10]) {
        [matrix setX:matrixSize / 2 + 7 y:matrixSize / 2 - 5 + i + i / 5];
      }
      if ([modeMessage get:29 - i]) {
        [matrix setX:matrixSize / 2 - 5 + i + i / 5 y:matrixSize / 2 + 7];
      }
      if ([modeMessage get:39 - i]) {
        [matrix setX:matrixSize / 2 - 7 y:matrixSize / 2 - 5 + i + i / 5];
      }
    }
  }
}

+ (ZXBitArray *)generateCheckWords:(ZXBitArray *)stuffedBits totalSymbolBits:(int)totalSymbolBits wordSize:(int)wordSize {
  int messageSizeInWords = (stuffedBits.size + wordSize - 1) / wordSize;
  for (int i = messageSizeInWords * wordSize - stuffedBits.size; i > 0; i--) {
    [stuffedBits appendBit:YES];
  }
  ZXReedSolomonEncoder *rs = [[ZXReedSolomonEncoder alloc] initWithField:[self getGF:wordSize]];
  int totalSizeInFullWords = totalSymbolBits / wordSize;

  int messageWords[totalSizeInFullWords];
  [self bitsToWords:stuffedBits wordSize:wordSize totalWords:totalSizeInFullWords message:messageWords];

  [rs encode:messageWords toEncodeLen:totalSizeInFullWords ecBytes:totalSizeInFullWords - messageSizeInWords];
  int startPad = totalSymbolBits % wordSize;
  ZXBitArray *messageBits = [[ZXBitArray alloc] init];
  [messageBits appendBits:0 numBits:startPad];
  for (int i = 0; i < totalSizeInFullWords; i++) {
    [messageBits appendBits:messageWords[i] numBits:wordSize];
  }
  return messageBits;
}

+ (void)bitsToWords:(ZXBitArray *)stuffedBits wordSize:(int)wordSize totalWords:(int)totalWords message:(int *)message {
  int i;
  int n;
  for (i = 0, n = stuffedBits.size / wordSize; i < n; i++) {
    int value = 0;
    for (int j = 0; j < wordSize; j++) {
      value |= [stuffedBits get:i * wordSize + j] ? (1 << (wordSize - j - 1)) : 0;
    }
    message[i] = value;
  }
}

+ (ZXGenericGF *)getGF:(int)wordSize {
  switch (wordSize) {
    case 4:
      return [ZXGenericGF AztecParam];
    case 6:
      return [ZXGenericGF AztecData6];
    case 8:
      return [ZXGenericGF AztecData8];
    case 10:
      return [ZXGenericGF AztecData10];
    case 12:
      return [ZXGenericGF AztecData12];
    default:
      return nil;
  }
}

+ (ZXBitArray *)stuffBits:(ZXBitArray *)bits wordSize:(int)wordSize {
  ZXBitArray *arrayOut = [[ZXBitArray alloc] init];

  // 1. stuff the bits
  int n = bits.size;
  int mask = (1 << wordSize) - 2;
  for (int i = 0; i < n; i += wordSize) {
    int word = 0;
    for (int j = 0; j < wordSize; j++) {
      if (i + j >= n || [bits get:i + j]) {
        word |= 1 << (wordSize - 1 - j);
      }
    }
    if ((word & mask) == mask) {
      [arrayOut appendBits:word & mask numBits:wordSize];
      i--;
    } else if ((word & mask) == 0) {
      [arrayOut appendBits:word | 1 numBits:wordSize];
      i--;
    } else {
      [arrayOut appendBits:word numBits:wordSize];
    }
  }

  // 2. pad last word to wordSize
  n = arrayOut.size;
  int remainder = n % wordSize;
  if (remainder != 0) {
    int j = 1;
    for (int i = 0; i < remainder; i++) {
      if (![arrayOut get:n - 1 - i]) {
        j = 0;
      }
    }
    for (int i = remainder; i < wordSize - 1; i++) {
      [arrayOut appendBit:YES];
    }
    [arrayOut appendBit:j == 0];
  }
  return arrayOut;
}

@end

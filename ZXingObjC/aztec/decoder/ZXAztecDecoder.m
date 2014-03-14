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

#import "ZXAztecDecoder.h"
#import "ZXAztecDetectorResult.h"
#import "ZXBitMatrix.h"
#import "ZXDecoderResult.h"
#import "ZXErrors.h"
#import "ZXGenericGF.h"
#import "ZXReedSolomonDecoder.h"

typedef enum {
  ZXAztecTableUpper = 0,
  ZXAztecTableLower,
  ZXAztecTableMixed,
  ZXAztecTableDigit,
  ZXAztecTablePunct,
  ZXAztecTableBinary
} ZXAztecTable;

static NSString *ZX_AZTEC_UPPER_TABLE[] = {
  @"CTRL_PS", @" ", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P",
  @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"CTRL_LL", @"CTRL_ML", @"CTRL_DL", @"CTRL_BS"
};

static NSString *ZX_AZTEC_LOWER_TABLE[] = {
  @"CTRL_PS", @" ", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p",
  @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"CTRL_US", @"CTRL_ML", @"CTRL_DL", @"CTRL_BS"
};

static NSString *ZX_AZTEC_MIXED_TABLE[] = {
  @"CTRL_PS", @" ", @"\1", @"\2", @"\3", @"\4", @"\5", @"\6", @"\7", @"\b", @"\t", @"\n",
  @"\13", @"\f", @"\r", @"\33", @"\34", @"\35", @"\36", @"\37", @"@", @"\\", @"^", @"_",
  @"`", @"|", @"~", @"\177", @"CTRL_LL", @"CTRL_UL", @"CTRL_PL", @"CTRL_BS"
};

static NSString *ZX_AZTEC_PUNCT_TABLE[] = {
  @"", @"\r", @"\r\n", @". ", @", ", @": ", @"!", @"\"", @"#", @"$", @"%", @"&", @"'", @"(", @")",
  @"*", @"+", @",", @"-", @".", @"/", @":", @";", @"<", @"=", @">", @"?", @"[", @"]", @"{", @"}", @"CTRL_UL"
};

static NSString *ZX_AZTEC_DIGIT_TABLE[] = {
  @"CTRL_PS", @" ", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @",", @".", @"CTRL_UL", @"CTRL_US"
};

@interface ZXAztecDecoder ()

@property (nonatomic, strong) ZXAztecDetectorResult *ddata;

@end

@implementation ZXAztecDecoder

- (ZXDecoderResult *)decode:(ZXAztecDetectorResult *)detectorResult error:(NSError **)error {
  self.ddata = detectorResult;
  ZXBitMatrix *matrix = [detectorResult bits];

  BOOL *rawbits;
  NSUInteger rawbitsLength = [self extractBits:matrix pBits:&rawbits];
  if (rawbitsLength == 0) {
    if (error) *error = FormatErrorInstance();
    return nil;
  }

  BOOL *correctedBits;
  NSUInteger correctedBitsLength = [self correctBits:rawbits bitsLength:rawbitsLength pBits:&correctedBits error:error];
  free(rawbits);
  rawbits = NULL;
  if (correctedBitsLength == 0) {
    return nil;
  }

  NSString *result = [[self class] encodedData:correctedBits length:correctedBitsLength];

  free(correctedBits);
  correctedBits = NULL;

  return [[ZXDecoderResult alloc] initWithRawBytes:NULL length:0 text:result byteSegments:nil ecLevel:nil];
}

+ (NSString *)highLevelDecode:(BOOL *)correctedBits length:(NSUInteger)correctedBitsLength {
  return [self encodedData:correctedBits length:correctedBitsLength];
}

/**
 * Gets the string encoded in the aztec code bits
 *
 * @return the decoded string
 */
+ (NSString *)encodedData:(BOOL *)correctedBits length:(NSUInteger)correctedBitsLength {
  int endIndex = (int)correctedBitsLength;
  ZXAztecTable latchTable = ZXAztecTableUpper; // table most recently latched to
  ZXAztecTable shiftTable = ZXAztecTableUpper; // table to use for the next read
  NSMutableString *result = [NSMutableString stringWithCapacity:20];
  int index = 0;
  while (index < endIndex) {
    if (shiftTable == ZXAztecTableBinary) {
      if (endIndex - index < 5) {
        break;
      }
      int length = [self readCode:correctedBits startIndex:index length:5];
      index += 5;
      if (length == 0) {
        if (endIndex - index < 11) {
          break;
        }

        length = [self readCode:correctedBits startIndex:index length:11] + 31;
        index += 11;
      }
      for (int charCount = 0; charCount < length; charCount++) {
        if (endIndex - index < 8) {
          index = endIndex;  // Force outer loop to exit
          break;
        }

        int code = [self readCode:correctedBits startIndex:index length:8];
        [result appendFormat:@"%C", (unichar)code];
        index += 8;
      }
      // Go back to whatever mode we had been in
      shiftTable = latchTable;
    } else {
      int size = shiftTable == ZXAztecTableDigit ? 4 : 5;
      if (endIndex - index < size) {
        break;
      }
      int code = [self readCode:correctedBits startIndex:index length:size];
      index += size;
      NSString *str = [self character:shiftTable code:code];
      if ([str hasPrefix:@"CTRL_"]) {
        // Table changes
        shiftTable = [self table:[str characterAtIndex:5]];
        if ([str characterAtIndex:6] == 'L') {
          latchTable = shiftTable;
        }
      } else {
        [result appendString:str];
        // Go back to whatever mode we had been in
        shiftTable = latchTable;
      }
    }
  }
  return [NSString stringWithString:result];
}

/**
 * gets the table corresponding to the char passed
 */
+ (ZXAztecTable)table:(unichar)t {
  switch (t) {
    case 'L':
      return ZXAztecTableLower;
    case 'P':
      return ZXAztecTablePunct;
    case 'M':
      return ZXAztecTableMixed;
    case 'D':
      return ZXAztecTableDigit;
    case 'B':
      return ZXAztecTableBinary;
    case 'U':
    default:
      return ZXAztecTableUpper;
  }
}

/**
 * Gets the character (or string) corresponding to the passed code in the given table
 *
 * @param table the table used
 * @param code the code of the character
 */
+ (NSString *)character:(ZXAztecTable)table code:(int)code {
  switch (table) {
    case ZXAztecTableUpper:
      return ZX_AZTEC_UPPER_TABLE[code];
    case ZXAztecTableLower:
      return ZX_AZTEC_LOWER_TABLE[code];
    case ZXAztecTableMixed:
      return ZX_AZTEC_MIXED_TABLE[code];
    case ZXAztecTablePunct:
      return ZX_AZTEC_PUNCT_TABLE[code];
    case ZXAztecTableDigit:
      return ZX_AZTEC_DIGIT_TABLE[code];
    default:
      // Should not reach here.
      @throw [NSException exceptionWithName:@"IllegalStateException" reason:@"Bad table" userInfo:nil];
  }
}

/**
 * <p>Performs RS error correction on an array of bits.</p>
 *
 * @return the number of corrected bits, or 0 if the input contains too many errors
 */
- (NSUInteger)correctBits:(BOOL *)rawbits bitsLength:(NSUInteger)rawbitsLength pBits:(BOOL **)pBits error:(NSError **)error {
  ZXGenericGF *gf;
  int codewordSize;

  if ([self.ddata nbLayers] <= 2) {
    codewordSize = 6;
    gf = [ZXGenericGF AztecData6];
  } else if ([self.ddata nbLayers] <= 8) {
    codewordSize = 8;
    gf = [ZXGenericGF AztecData8];
  } else if ([self.ddata nbLayers] <= 22) {
    codewordSize = 10;
    gf = [ZXGenericGF AztecData10];
  } else {
    codewordSize = 12;
    gf = [ZXGenericGF AztecData12];
  }

  int numDataCodewords = [self.ddata nbDatablocks];
  int numCodewords = (int)rawbitsLength / codewordSize;
  int offset = rawbitsLength % codewordSize;
  int numECCodewords = numCodewords - numDataCodewords;

  int dataWords[numCodewords];
  for (int i = 0; i < sizeof(dataWords)/sizeof(int); i++, offset += codewordSize) {
    dataWords[i] = [[self class] readCode:rawbits startIndex:offset length:codewordSize];
  }

  ZXReedSolomonDecoder *rsDecoder = [[ZXReedSolomonDecoder alloc] initWithField:gf];
  NSError *decodeError = nil;
  if (![rsDecoder decode:dataWords receivedLen:sizeof(dataWords)/sizeof(int) twoS:numECCodewords error:&decodeError]) {
    if (decodeError.code == ZXReedSolomonError) {
      if (error) *error = FormatErrorInstance();
    } else {
      if (error) *error = decodeError;
    }
    return 0;
  }

  // Now perform the unstuffing operation.
  // First, count how many bits are going to be thrown out as stuffing
  int mask = (1 << codewordSize) - 1;
  int stuffedBits = 0;
  for (int i = 0; i < numDataCodewords; i++) {
    int dataWord = dataWords[i];
    if (dataWord == 0 || dataWord == mask) {
      if (error) *error = FormatErrorInstance();
      return 0;
    } else if (dataWord == 1 || dataWord == mask - 1) {
      stuffedBits++;
    }
  }

  // Now, actually unpack the bits and remove the stuffing
  NSUInteger correctedBitsLength = numDataCodewords * codewordSize - stuffedBits;
  BOOL *correctedBits = (BOOL *)calloc(correctedBitsLength, sizeof(BOOL));
  int index = 0;
  for (int i = 0; i < numDataCodewords; i++) {
    int dataWord = dataWords[i];
    if (dataWord == 1 || dataWord == mask - 1) {
      // next codewordSize-1 bits are all zeros or all ones
      memset(correctedBits + index * sizeof(BOOL), dataWord > 1, codewordSize - 1);
      index += codewordSize - 1;
    } else {
      for (int bit = codewordSize - 1; bit >= 0; --bit) {
        correctedBits[index++] = (dataWord & (1 << bit)) != 0;
      }
    }
  }
  NSAssert(index == correctedBitsLength, @"Expected index to equal %d (got %d)", (int)correctedBitsLength, index);

  *pBits = correctedBits;
  return correctedBitsLength;
}

/**
 * Gets the array of bits from an Aztec Code matrix
 *
 * @return the size of the array of bits
 */
- (NSUInteger)extractBits:(ZXBitMatrix *)matrix pBits:(BOOL **)pBits {
  BOOL compact = self.ddata.isCompact;
  int layers = self.ddata.nbLayers;
  int baseMatrixSize = compact ? 11 + layers * 4 : 14 + layers * 4; // not including alignment lines
  int alignmentMap[baseMatrixSize];
  memset(alignmentMap, 0, sizeof(alignmentMap)/sizeof(int));
  NSUInteger rawbitsLength = [self totalBitsInLayer:layers compact:compact];
  BOOL *rawbits = (BOOL *)calloc(rawbitsLength, sizeof(BOOL));

  if (compact) {
    for (int i = 0; i < sizeof(alignmentMap)/sizeof(int); i++) {
      alignmentMap[i] = i;
    }
  } else {
    int matrixSize = baseMatrixSize + 1 + 2 * ((baseMatrixSize / 2 - 1) / 15);
    int origCenter = baseMatrixSize / 2;
    int center = matrixSize / 2;
    for (int i = 0; i < origCenter; i++) {
      int newOffset = i + i / 15;
      alignmentMap[origCenter - i - 1] = center - newOffset - 1;
      alignmentMap[origCenter + i] = center + newOffset + 1;
    }
  }
  for (int i = 0, rowOffset = 0; i < layers; i++) {
    int rowSize = compact ? (layers - i) * 4 + 9 : (layers - i) * 4 + 12;
    // The top-left most point of this layer is <low, low> (not including alignment lines)
    int low = i * 2;
    // The bottom-right most point of this layer is <high, high> (not including alignment lines)
    int high = baseMatrixSize - 1 - low;
    // We pull bits from the two 2 x rowSize columns and two rowSize x 2 rows
    for (int j = 0; j < rowSize; j++) {
      int columnOffset = j * 2;
      for (int k = 0; k < 2; k++) {
        // left column
        rawbits[rowOffset + columnOffset + k] =
          [matrix getX:alignmentMap[low + k] y:alignmentMap[low + j]];
        // bottom row
        rawbits[rowOffset + 2 * rowSize + columnOffset + k] =
          [matrix getX:alignmentMap[low + j] y:alignmentMap[high - k]];
        // right column
        rawbits[rowOffset + 4 * rowSize + columnOffset + k] =
          [matrix getX:alignmentMap[high - k] y:alignmentMap[high - j]];
        // top row
        rawbits[rowOffset + 6 * rowSize + columnOffset + k] =
          [matrix getX:alignmentMap[high - j] y:alignmentMap[low + k]];
      }
    }
    rowOffset += rowSize * 8;
  }

  *pBits = rawbits;
  return rawbitsLength;
}

/**
 * Reads a code of given length and at given index in an array of bits
 */
+ (int)readCode:(BOOL *)rawbits startIndex:(int)startIndex length:(int)length {
  int res = 0;
  for (int i = startIndex; i < startIndex + length; i++) {
    res <<= 1;
    if (rawbits[i]) {
      res++;
    }
  }
  return res;
}

- (int)totalBitsInLayer:(int)layers compact:(BOOL)compact {
  return ((compact ? 88 : 112) + 16 * layers) * layers;
}

@end

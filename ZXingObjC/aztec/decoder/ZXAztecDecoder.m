#import "ZXAztecDecoder.h"
#import "ZXAztecDetectorResult.h"
#import "ZXBitMatrix.h"
#import "ZXDecoderResult.h"
#import "ZXFormatException.h"
#import "ZXGenericGF.h"
#import "ZXReedSolomonDecoder.h"
#import "ZXReedSolomonException.h"

enum {
  UPPER = 0,
  LOWER,
  MIXED,
  DIGIT,
  PUNCT,
  BINARY
};

static int NB_BITS_COMPACT[] = {
  0, 104, 240, 408, 608
};

static int NB_BITS[] = {
  0, 128, 288, 480, 704, 960, 1248, 1568, 1920, 2304, 2720, 3168, 3648, 4160, 4704, 5280, 5888, 6528,
  7200, 7904, 8640, 9408, 10208, 11040, 11904, 12800, 13728, 14688, 15680, 16704, 17760, 18848, 19968
};

static int NB_DATABLOCK_COMPACT[] = {
  0, 17, 40, 51, 76
};

static int NB_DATABLOCK[] = {
  0, 21, 48, 60, 88, 120, 156, 196, 240, 230, 272, 316, 364, 416, 470, 528, 588, 652, 720, 790, 864,
  940, 1020, 920, 992, 1066, 1144, 1224, 1306, 1392, 1480, 1570, 1664
};

static NSString* UPPER_TABLE[] = {
  @"CTRL_PS", @" ", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P",
  @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"CTRL_LL", @"CTRL_ML", @"CTRL_DL", @"CTRL_BS"
};

static NSString* LOWER_TABLE[] = {
  @"CTRL_PS", @" ", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p",
  @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"CTRL_US", @"CTRL_ML", @"CTRL_DL", @"CTRL_BS"
};

static NSString* MIXED_TABLE[] = {
  @"CTRL_PS", @" ", @"\1", @"\2", @"\3", @"\4", @"\5", @"\6", @"\7", @"\b", @"\t", @"\n",
  @"\13", @"\f", @"\r", @"\33", @"\34", @"\35", @"\36", @"\37", @"@", @"\\", @"^", @"_",
  @"`", @"|", @"~", @"\177", @"CTRL_LL", @"CTRL_UL", @"CTRL_PL", @"CTRL_BS"
};

static NSString* PUNCT_TABLE[] = {
  @"", @"\r", @"\r\n", @". ", @", ", @": ", @"!", @"\"", @"#", @"$", @"%", @"&", @"'", @"(", @")",
  @"*", @"+", @",", @"-", @".", @"/", @":", @";", @"<", @"=", @">", @"?", @"[", @"]", @"{", @"}", @"CTRL_UL"
};

static NSString* DIGIT_TABLE[] = {
  @"CTRL_PS", @" ", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @",", @".", @"CTRL_UL", @"CTRL_US"
};

@interface ZXAztecDecoder ()

- (NSString *) character:(int)table code:(int)code;
- (NSArray *) correctBits:(NSArray *)rawbits;
- (NSString *) encodedData:(NSArray *)correctedBits;
- (NSArray *) extractBits:(ZXBitMatrix *)matrix;
- (int) readCode:(NSArray *)rawbits startIndex:(int)startIndex length:(unsigned int)length;
- (ZXBitMatrix *) removeDashedLines:(ZXBitMatrix *)matrix;
- (int) table:(unichar)t;

@end

@implementation ZXAztecDecoder

- (ZXDecoderResult *) decode:(ZXAztecDetectorResult *)detectorResult {
  ddata = detectorResult;
  ZXBitMatrix * matrix = [detectorResult bits];
  if (![ddata compact]) {
    matrix = [self removeDashedLines:[ddata bits]];
  }
  NSArray * rawbits = [self extractBits:matrix];
  NSArray * correctedBits = [self correctBits:rawbits];
  NSString * result = [self encodedData:correctedBits];
  return [[[ZXDecoderResult alloc] init:nil length:0 text:result byteSegments:nil ecLevel:nil] autorelease];
}


/**
 * 
 * Gets the string encoded in the aztec code bits
 * 
 * @return the decoded string
 * @throws FormatException if the input is not valid
 */
- (NSString *) encodedData:(NSArray *)correctedBits {
  int endIndex = codewordSize * [ddata nbDatablocks] - invertedBitCount;
  if (endIndex > [correctedBits count]) {
    @throw [ZXFormatException formatInstance];
  }
  int lastTable = UPPER;
  int table = UPPER;
  int startIndex = 0;
  NSMutableString * result = [NSMutableString stringWithCapacity:20];
  BOOL end = NO;
  BOOL shift = NO;
  BOOL switchShift = NO;

  while (!end) {
    if (shift) {
      switchShift = YES;
    }
     else {
      lastTable = table;
    }
    int code;

    switch (table) {
    case BINARY:
      if (endIndex - startIndex < 8) {
        end = YES;
        break;
      }
      code = [self readCode:correctedBits startIndex:startIndex length:8];
      startIndex += 8;
      unichar uCode = (unichar)code;
      [result appendString:[NSString stringWithCharacters:&uCode length:1]];
      break;
      default: {
        int size = 5;
        if (table == DIGIT) {
          size = 4;
        }
        if (endIndex - startIndex < size) {
          end = YES;
          break;
        }
        code = [self readCode:correctedBits startIndex:startIndex length:size];
        startIndex += size;
        NSString * str = [self character:table code:code];
        if ([str hasPrefix:@"CTRL_"]) {
          table = [self table:[str characterAtIndex:5]];
          if ([str characterAtIndex:6] == 'S') {
            shift = YES;
          }
        }
         else {
          [result appendString:str];
        }
        break;
      }
    }
    if (switchShift) {
      table = lastTable;
      shift = NO;
      switchShift = NO;
    }
  }

  return result;
}


/**
 * gets the table corresponding to the char passed
 */
- (int) table:(unichar)t {
  int table = UPPER;

  switch (t) {
  case 'U':
    table = UPPER;
    break;
  case 'L':
    table = LOWER;
    break;
  case 'P':
    table = PUNCT;
    break;
  case 'M':
    table = MIXED;
    break;
  case 'D':
    table = DIGIT;
    break;
  case 'B':
    table = BINARY;
    break;
  }
  return table;
}


/**
 * 
 * Gets the character (or string) corresponding to the passed code in the given table
 * 
 * @param table the table used
 * @param code the code of the character
 */
- (NSString *) character:(int)table code:(int)code {

  switch (table) {
  case UPPER:
    return UPPER_TABLE[code];
  case LOWER:
    return LOWER_TABLE[code];
  case MIXED:
    return MIXED_TABLE[code];
  case PUNCT:
    return PUNCT_TABLE[code];
  case DIGIT:
    return DIGIT_TABLE[code];
  default:
    return @"";
  }
}


/**
 * 
 * <p> performs RS error correction on an array of bits </p>
 * 
 * @return the corrected array
 * @throws FormatException if the input contains too many errors
 */
- (NSArray *) correctBits:(NSArray *)rawbits {
  ZXGenericGF * gf;
  if ([ddata nbLayers] <= 2) {
    codewordSize = 6;
    gf = [ZXGenericGF AztecData6];
  } else if ([ddata nbLayers] <= 8) {
    codewordSize = 8;
    gf = [ZXGenericGF AztecData8];
  } else if ([ddata nbLayers] <= 22) {
    codewordSize = 10;
    gf = [ZXGenericGF AztecData10];
  } else {
    codewordSize = 12;
    gf = [ZXGenericGF AztecData12];
  }
  int numDataCodewords = [ddata nbDatablocks];
  int numECCodewords;
  int offset;
  if ([ddata compact]) {
    offset = NB_BITS_COMPACT[[ddata nbLayers]] - numCodewords * codewordSize;
    numECCodewords = NB_DATABLOCK_COMPACT[[ddata nbLayers]] - numDataCodewords;
  }
   else {
    offset = NB_BITS[[ddata nbLayers]] - numCodewords * codewordSize;
    numECCodewords = NB_DATABLOCK[[ddata nbLayers]] - numDataCodewords;
  }
  NSMutableArray * dataWords = [NSMutableArray array];

  for (int i = 0; i < numCodewords; i++) {
    [dataWords addObject:[NSNumber numberWithInt:0]];
    int flag = 1;

    for (int j = 1; j <= codewordSize; j++) {
      if ([rawbits objectAtIndex:codewordSize * i + codewordSize - j + offset]) {
        [dataWords replaceObjectAtIndex:i withObject:
         [NSNumber numberWithInt:[[dataWords objectAtIndex:i] intValue] + flag]];
      }
      flag <<= 1;
    }
  }


  @try {
    ZXReedSolomonDecoder * rsDecoder = [[[ZXReedSolomonDecoder alloc] initWithField:gf] autorelease];
    [rsDecoder decode:dataWords twoS:numECCodewords];
  }
  @catch (ZXReedSolomonException * rse) {
    @throw [ZXFormatException formatInstance];
  }
  offset = 0;
  invertedBitCount = 0;
  NSMutableArray * correctedBits = [NSMutableArray array];
  for (int i = 0; i < numDataCodewords*codewordSize; i++) {
    [correctedBits addObject:[NSNull null]];
  }

  for (int i = 0; i < numDataCodewords; i++) {
    BOOL seriesColor = NO;
    int seriesCount = 0;
    int flag = 1 << (codewordSize - 1);

    for (int j = 0; j < codewordSize; j++) {
      BOOL color = ([[dataWords objectAtIndex:i] intValue] & flag) == flag;
      if (seriesCount == codewordSize - 1) {
        if (color == seriesColor) {
          @throw [ZXFormatException formatInstance];
        }
        seriesColor = NO;
        seriesCount = 0;
        offset++;
        invertedBitCount++;
      }
       else {
        if (seriesColor == color) {
          seriesCount++;
        }
         else {
          seriesCount = 1;
          seriesColor = color;
        }
        [correctedBits replaceObjectAtIndex:i * codewordSize + j - offset withObject:[NSNumber numberWithBool:color]];
      }

      flag = (int)(((unsigned int)flag) << 1);
    }
  }

  return correctedBits;
}


/**
 * 
 * Gets the array of bits from an Aztec Code matrix
 * 
 * @return the array of bits
 * @throws FormatException if the matrix is not a valid aztec code
 */
- (NSArray *) extractBits:(ZXBitMatrix *)matrix {
  NSMutableArray * rawbits;
  int capacity;
  if ([ddata compact]) {
    if ([ddata nbLayers] > (sizeof(NB_BITS_COMPACT) / sizeof(int))) {
      @throw [ZXFormatException formatInstance];
    }
    capacity = NB_BITS_COMPACT[[ddata nbLayers]];
    numCodewords = NB_DATABLOCK_COMPACT[[ddata nbLayers]];
  } else {
    if ([ddata nbLayers] > (sizeof(NB_BITS) / sizeof(int))) {
      @throw [ZXFormatException formatInstance];
    }
    capacity = NB_BITS[[ddata nbLayers]];
    numCodewords = NB_DATABLOCK[[ddata nbLayers]];
  }
  
  rawbits = [NSMutableArray arrayWithCapacity:capacity];
  for (int i = 0; i < capacity; i++) {
    [rawbits addObject:[NSNull null]];
  }

  int layer = [ddata nbLayers];
  int size = matrix.height;
  int rawbitsOffset = 0;
  int matrixOffset = 0;

  while (layer != 0) {
    int flip = 0;

    for (int i = 0; i < 2 * size - 4; i++) {
      [rawbits replaceObjectAtIndex:rawbitsOffset + i
                         withObject:[NSNumber numberWithBool:[matrix get:matrixOffset + flip y:matrixOffset + i / 2]]];

      [rawbits replaceObjectAtIndex:rawbitsOffset + 2 * size - 4 + i
                         withObject:[NSNumber numberWithBool:[matrix get:matrixOffset + i / 2 y:matrixOffset + size - 1 - flip]]];

      flip = (flip + 1) % 2;
    }

    flip = 0;

    for (int i = 2 * size + 1; i > 5; i--) {
      [rawbits replaceObjectAtIndex:rawbitsOffset + 4 * size - 8 + (2 * size - i) + 1
                         withObject:[NSNumber numberWithBool:[matrix get:matrixOffset + size - 1 - flip y:matrixOffset + i / 2 - 1]]];

      [rawbits replaceObjectAtIndex:rawbitsOffset + 6 * size - 12 + (2 * size - i) + 1
                         withObject:[NSNumber numberWithBool:[matrix get:matrixOffset + i / 2 - 1 y:matrixOffset + flip]]];

      flip = (flip + 1) % 2;
    }

    matrixOffset += 2;
    rawbitsOffset += 8 * size - 16;
    layer--;
    size -= 4;
  }

  return rawbits;
}


/**
 * Transforms an Aztec code matrix by removing the control dashed lines
 */
- (ZXBitMatrix *) removeDashedLines:(ZXBitMatrix *)matrix {
  int nbDashed = 1 + 2 * ((matrix.width - 1) / 2 / 16);
  ZXBitMatrix * newMatrix = [[[ZXBitMatrix alloc] initWithWidth:matrix.width - nbDashed height:matrix.height - nbDashed] autorelease];
  int nx = 0;

  for (int x = 0; x < matrix.width; x++) {
    if ((matrix.width / 2 - x) % 16 == 0) {
      continue;
    }
    int ny = 0;

    for (int y = 0; y < matrix.height; y++) {
      if ((matrix.width / 2 - y) % 16 == 0) {
        continue;
      }
      if ([matrix get:x y:y]) {
        [newMatrix set:nx y:ny];
      }
      ny++;
    }

    nx++;
  }

  return newMatrix;
}


/**
 * Reads a code of given length and at given index in an array of bits
 */
- (int) readCode:(NSArray *)rawbits startIndex:(int)startIndex length:(unsigned int)length {
  int res = 0;

  for (int i = startIndex; i < startIndex + length; i++) {
    res <<= 1;
    if ([[rawbits objectAtIndex:i] boolValue]) {
      res++;
    }
  }

  return res;
}

- (void) dealloc {
  [ddata release];
  [super dealloc];
}

@end

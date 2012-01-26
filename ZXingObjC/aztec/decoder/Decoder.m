#import "Decoder.h"

int const UPPER = 0;
int const LOWER = 1;
int const MIXED = 2;
int const DIGIT = 3;
int const PUNCT = 4;
int const BINARY = 5;
NSArray * const NB_BITS_COMPACT = [NSArray arrayWithObjects:0, 104, 240, 408, 608, nil];
NSArray * const NB_BITS = [NSArray arrayWithObjects:0, 128, 288, 480, 704, 960, 1248, 1568, 1920, 2304, 2720, 3168, 3648, 4160, 4704, 5280, 5888, 6528, 7200, 7904, 8640, 9408, 10208, 11040, 11904, 12800, 13728, 14688, 15680, 16704, 17760, 18848, 19968, nil];
NSArray * const NB_DATABLOCK_COMPACT = [NSArray arrayWithObjects:0, 17, 40, 51, 76, nil];
NSArray * const NB_DATABLOCK = [NSArray arrayWithObjects:0, 21, 48, 60, 88, 120, 156, 196, 240, 230, 272, 316, 364, 416, 470, 528, 588, 652, 720, 790, 864, 940, 1020, 920, 992, 1066, 1144, 1224, 1306, 1392, 1480, 1570, 1664, nil];
NSArray * const UPPER_TABLE = [NSArray arrayWithObjects:@"CTRL_PS", @" ", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"CTRL_LL", @"CTRL_ML", @"CTRL_DL", @"CTRL_BS", nil];
NSArray * const LOWER_TABLE = [NSArray arrayWithObjects:@"CTRL_PS", @" ", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"CTRL_US", @"CTRL_ML", @"CTRL_DL", @"CTRL_BS", nil];
NSArray * const MIXED_TABLE = [NSArray arrayWithObjects:@"CTRL_PS", @" ", @"\1", @"\2", @"\3", @"\4", @"\5", @"\6", @"\7", @"\b", @"\t", @"\n", @"\13", @"\f", @"\r", @"\33", @"\34", @"\35", @"\36", @"\37", @"@", @"\\", @"^", @"_", @"`", @"|", @"~", @"\177", @"CTRL_LL", @"CTRL_UL", @"CTRL_PL", @"CTRL_BS", nil];
NSArray * const PUNCT_TABLE = [NSArray arrayWithObjects:@"", @"\r", @"\r\n", @". ", @", ", @": ", @"!", @"\"", @"#", @"$", @"%", @"&", @"'", @"(", @")", @"*", @"+", @",", @"-", @".", @"/", @":", @";", @"<", @"=", @">", @"?", @"[", @"]", @"{", @"}", @"CTRL_UL", nil];
NSArray * const DIGIT_TABLE = [NSArray arrayWithObjects:@"CTRL_PS", @" ", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @",", @".", @"CTRL_UL", @"CTRL_US", nil];

@implementation Decoder

- (DecoderResult *) decode:(AztecDetectorResult *)detectorResult {
  ddata = detectorResult;
  BitMatrix * matrix = [detectorResult bits];
  if (![ddata compact]) {
    matrix = [self removeDashedLines:[ddata bits]];
  }
  NSArray * rawbits = [self extractBits:matrix];
  NSArray * correctedBits = [self correctBits:rawbits];
  NSString * result = [self getEncodedData:correctedBits];
  return [[[DecoderResult alloc] init:nil param1:result param2:nil param3:nil] autorelease];
}


/**
 * 
 * Gets the string encoded in the aztec code bits
 * 
 * @return the decoded string
 * @throws FormatException if the input is not valid
 */
- (NSString *) getEncodedData:(NSArray *)correctedBits {
  int endIndex = codewordSize * [ddata nbDatablocks] - invertedBitCount;
  if (endIndex > correctedBits.length) {
    @throw [FormatException formatInstance];
  }
  int lastTable = UPPER;
  int table = UPPER;
  int startIndex = 0;
  StringBuffer * result = [[[StringBuffer alloc] init:20] autorelease];
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
      [result append:(unichar)code];
      break;
    default:
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
      NSString * str = [self getCharacter:table code:code];
      if ([str hasPrefix:@"CTRL_"]) {
        table = [self getTable:[str characterAtIndex:5]];
        if ([str characterAtIndex:6] == 'S') {
          shift = YES;
        }
      }
       else {
        [result append:str];
      }
      break;
    }
    if (switchShift) {
      table = lastTable;
      shift = NO;
      switchShift = NO;
    }
  }

  return [result description];
}


/**
 * gets the table corresponding to the char passed
 */
+ (int) getTable:(unichar)t {
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
+ (NSString *) getCharacter:(int)table code:(int)code {

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
  GenericGF * gf;
  if ([ddata nbLayers] <= 2) {
    codewordSize = 6;
    gf = GenericGF.AZTEC_DATA_6;
  }
   else if ([ddata nbLayers] <= 8) {
    codewordSize = 8;
    gf = GenericGF.AZTEC_DATA_8;
  }
   else if ([ddata nbLayers] <= 22) {
    codewordSize = 10;
    gf = GenericGF.AZTEC_DATA_10;
  }
   else {
    codewordSize = 12;
    gf = GenericGF.AZTEC_DATA_12;
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
  NSArray * dataWords = [NSArray array];

  for (int i = 0; i < numCodewords; i++) {
    int flag = 1;

    for (int j = 1; j <= codewordSize; j++) {
      if (rawbits[codewordSize * i + codewordSize - j + offset]) {
        dataWords[i] += flag;
      }
      flag <<= 1;
    }

  }


  @try {
    ReedSolomonDecoder * rsDecoder = [[[ReedSolomonDecoder alloc] init:gf] autorelease];
    [rsDecoder decode:dataWords param1:numECCodewords];
  }
  @catch (ReedSolomonException * rse) {
    @throw [FormatException formatInstance];
  }
  offset = 0;
  invertedBitCount = 0;
  NSArray * correctedBits = [NSArray array];

  for (int i = 0; i < numDataCodewords; i++) {
    BOOL seriesColor = NO;
    int seriesCount = 0;
    int flag = 1 << (codewordSize - 1);

    for (int j = 0; j < codewordSize; j++) {
      BOOL color = (dataWords[i] & flag) == flag;
      if (seriesCount == codewordSize - 1) {
        if (color == seriesColor) {
          @throw [FormatException formatInstance];
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
        correctedBits[i * codewordSize + j - offset] = color;
      }
      flag >>>= 1;
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
- (NSArray *) extractBits:(BitMatrix *)matrix {
  NSArray * rawbits;
  if ([ddata compact]) {
    if ([ddata nbLayers] > NB_BITS_COMPACT.length) {
      @throw [FormatException formatInstance];
    }
    rawbits = [NSArray array];
    numCodewords = NB_DATABLOCK_COMPACT[[ddata nbLayers]];
  }
   else {
    if ([ddata nbLayers] > NB_BITS.length) {
      @throw [FormatException formatInstance];
    }
    rawbits = [NSArray array];
    numCodewords = NB_DATABLOCK[[ddata nbLayers]];
  }
  int layer = [ddata nbLayers];
  int size = matrix.height;
  int rawbitsOffset = 0;
  int matrixOffset = 0;

  while (layer != 0) {
    int flip = 0;

    for (int i = 0; i < 2 * size - 4; i++) {
      rawbits[rawbitsOffset + i] = [matrix get:matrixOffset + flip param1:matrixOffset + i / 2];
      rawbits[rawbitsOffset + 2 * size - 4 + i] = [matrix get:matrixOffset + i / 2 param1:matrixOffset + size - 1 - flip];
      flip = (flip + 1) % 2;
    }

    flip = 0;

    for (int i = 2 * size + 1; i > 5; i--) {
      rawbits[rawbitsOffset + 4 * size - 8 + (2 * size - i) + 1] = [matrix get:matrixOffset + size - 1 - flip param1:matrixOffset + i / 2 - 1];
      rawbits[rawbitsOffset + 6 * size - 12 + (2 * size - i) + 1] = [matrix get:matrixOffset + i / 2 - 1 param1:matrixOffset + flip];
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
+ (BitMatrix *) removeDashedLines:(BitMatrix *)matrix {
  int nbDashed = 1 + 2 * ((matrix.width - 1) / 2 / 16);
  BitMatrix * newMatrix = [[[BitMatrix alloc] init:matrix.width - nbDashed param1:matrix.height - nbDashed] autorelease];
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
      if ([matrix get:x param1:y]) {
        [newMatrix set:nx param1:ny];
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
+ (int) readCode:(NSArray *)rawbits startIndex:(int)startIndex length:(int)length {
  int res = 0;

  for (int i = startIndex; i < startIndex + length; i++) {
    res <<= 1;
    if (rawbits[i]) {
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

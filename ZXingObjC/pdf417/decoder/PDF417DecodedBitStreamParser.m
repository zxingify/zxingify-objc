#import "PDF417DecodedBitStreamParser.h"

int const TEXT_COMPACTION_MODE_LATCH = 900;
int const BYTE_COMPACTION_MODE_LATCH = 901;
int const NUMERIC_COMPACTION_MODE_LATCH = 902;
int const BYTE_COMPACTION_MODE_LATCH_6 = 924;
int const BEGIN_MACRO_PDF417_CONTROL_BLOCK = 928;
int const BEGIN_MACRO_PDF417_OPTIONAL_FIELD = 923;
int const MACRO_PDF417_TERMINATOR = 922;
int const MODE_SHIFT_TO_BYTE_COMPACTION_MODE = 913;
int const MAX_NUMERIC_CODEWORDS = 15;
int const ALPHA = 0;
int const LOWER = 1;
int const MIXED = 2;
int const PUNCT = 3;
int const ALPHA_SHIFT = 4;
int const PUNCT_SHIFT = 5;
int const PL = 25;
int const LL = 27;
int const AS = 27;
int const ML = 28;
int const AL = 28;
int const PS = 29;
int const PAL = 29;
NSArray * const PUNCT_CHARS = [NSArray arrayWithObjects:';', '<', '>', '@', '[', 92, '}', '_', 96, '~', '!', 13, 9, ',', ':', 10, '-', '.', '$', '/', 34, '|', '*', '(', ')', '?', '{', '}', 39, nil];
NSArray * const MIXED_CHARS = [NSArray arrayWithObjects:'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '&', 13, 9, ',', ':', '#', '-', '.', '$', '/', '+', '%', '*', '=', '^', nil];
NSArray * const EXP900 = [NSArray arrayWithObjects:@"000000000000000000000000000000000000000000001", @"000000000000000000000000000000000000000000900", @"000000000000000000000000000000000000000810000", @"000000000000000000000000000000000000729000000", @"000000000000000000000000000000000656100000000", @"000000000000000000000000000000590490000000000", @"000000000000000000000000000531441000000000000", @"000000000000000000000000478296900000000000000", @"000000000000000000000430467210000000000000000", @"000000000000000000387420489000000000000000000", @"000000000000000348678440100000000000000000000", @"000000000000313810596090000000000000000000000", @"000000000282429536481000000000000000000000000", @"000000254186582832900000000000000000000000000", @"000228767924549610000000000000000000000000000", @"205891132094649000000000000000000000000000000", nil];

@implementation PDF417DecodedBitStreamParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (DecoderResult *) decode:(NSArray *)codewords {
  NSMutableString * result = [[[NSMutableString alloc] init:100] autorelease];
  int codeIndex = 1;
  int code = codewords[codeIndex++];

  while (codeIndex < codewords[0]) {

    switch (code) {
    case TEXT_COMPACTION_MODE_LATCH:
      codeIndex = [self textCompaction:codewords codeIndex:codeIndex result:result];
      break;
    case BYTE_COMPACTION_MODE_LATCH:
      codeIndex = [self byteCompaction:code codewords:codewords codeIndex:codeIndex result:result];
      break;
    case NUMERIC_COMPACTION_MODE_LATCH:
      codeIndex = [self numericCompaction:codewords codeIndex:codeIndex result:result];
      break;
    case MODE_SHIFT_TO_BYTE_COMPACTION_MODE:
      codeIndex = [self byteCompaction:code codewords:codewords codeIndex:codeIndex result:result];
      break;
    case BYTE_COMPACTION_MODE_LATCH_6:
      codeIndex = [self byteCompaction:code codewords:codewords codeIndex:codeIndex result:result];
      break;
    default:
      codeIndex--;
      codeIndex = [self textCompaction:codewords codeIndex:codeIndex result:result];
      break;
    }
    if (codeIndex < codewords.length) {
      code = codewords[codeIndex++];
    }
     else {
      @throw [FormatException formatInstance];
    }
  }

  return [[[DecoderResult alloc] init:nil param1:[result description] param2:nil param3:nil] autorelease];
}


/**
 * Text Compaction mode (see 5.4.1.5) permits all printable ASCII characters to be
 * encoded, i.e. values 32 - 126 inclusive in accordance with ISO/IEC 646 (IRV), as
 * well as selected control characters.
 * 
 * @param codewords The array of codewords (data + error)
 * @param codeIndex The current index into the codeword array.
 * @param result    The decoded data is appended to the result.
 * @return The next index into the codeword array.
 */
+ (int) textCompaction:(NSArray *)codewords codeIndex:(int)codeIndex result:(NSMutableString *)result {
  NSArray * textCompactionData = [NSArray array];
  NSArray * byteCompactionData = [NSArray array];
  int index = 0;
  BOOL end = NO;

  while ((codeIndex < codewords[0]) && !end) {
    int code = codewords[codeIndex++];
    if (code < TEXT_COMPACTION_MODE_LATCH) {
      textCompactionData[index] = code / 30;
      textCompactionData[index + 1] = code % 30;
      index += 2;
    }
     else {

      switch (code) {
      case TEXT_COMPACTION_MODE_LATCH:
        codeIndex--;
        end = YES;
        break;
      case BYTE_COMPACTION_MODE_LATCH:
        codeIndex--;
        end = YES;
        break;
      case NUMERIC_COMPACTION_MODE_LATCH:
        codeIndex--;
        end = YES;
        break;
      case MODE_SHIFT_TO_BYTE_COMPACTION_MODE:
        textCompactionData[index] = MODE_SHIFT_TO_BYTE_COMPACTION_MODE;
        code = codewords[codeIndex++];
        byteCompactionData[index] = code;
        index++;
        break;
      case BYTE_COMPACTION_MODE_LATCH_6:
        codeIndex--;
        end = YES;
        break;
      }
    }
  }

  [self decodeTextCompaction:textCompactionData byteCompactionData:byteCompactionData length:index result:result];
  return codeIndex;
}


/**
 * The Text Compaction mode includes all the printable ASCII characters
 * (i.e. values from 32 to 126) and three ASCII control characters: HT or tab
 * (ASCII value 9), LF or line feed (ASCII value 10), and CR or carriage
 * return (ASCII value 13). The Text Compaction mode also includes various latch
 * and shift characters which are used exclusively within the mode. The Text
 * Compaction mode encodes up to 2 characters per codeword. The compaction rules
 * for converting data into PDF417 codewords are defined in 5.4.2.2. The sub-mode
 * switches are defined in 5.4.2.3.
 * 
 * @param textCompactionData The text compaction data.
 * @param byteCompactionData The byte compaction data if there
 * was a mode shift.
 * @param length             The size of the text compaction and byte compaction data.
 * @param result             The decoded data is appended to the result.
 */
+ (void) decodeTextCompaction:(NSArray *)textCompactionData byteCompactionData:(NSArray *)byteCompactionData length:(int)length result:(NSMutableString *)result {
  int subMode = ALPHA;
  int priorToShiftMode = ALPHA;
  int i = 0;

  while (i < length) {
    int subModeCh = textCompactionData[i];
    unichar ch = 0;

    switch (subMode) {
    case ALPHA:
      if (subModeCh < 26) {
        ch = (unichar)('A' + subModeCh);
      }
       else {
        if (subModeCh == 26) {
          ch = ' ';
        }
         else if (subModeCh == LL) {
          subMode = LOWER;
        }
         else if (subModeCh == ML) {
          subMode = MIXED;
        }
         else if (subModeCh == PS) {
          priorToShiftMode = subMode;
          subMode = PUNCT_SHIFT;
        }
         else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
          [result append:(unichar)byteCompactionData[i]];
        }
      }
      break;
    case LOWER:
      if (subModeCh < 26) {
        ch = (unichar)('a' + subModeCh);
      }
       else {
        if (subModeCh == 26) {
          ch = ' ';
        }
         else if (subModeCh == AS) {
          priorToShiftMode = subMode;
          subMode = ALPHA_SHIFT;
        }
         else if (subModeCh == ML) {
          subMode = MIXED;
        }
         else if (subModeCh == PS) {
          priorToShiftMode = subMode;
          subMode = PUNCT_SHIFT;
        }
         else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
          [result append:(unichar)byteCompactionData[i]];
        }
      }
      break;
    case MIXED:
      if (subModeCh < PL) {
        ch = MIXED_CHARS[subModeCh];
      }
       else {
        if (subModeCh == PL) {
          subMode = PUNCT;
        }
         else if (subModeCh == 26) {
          ch = ' ';
        }
         else if (subModeCh == LL) {
          subMode = LOWER;
        }
         else if (subModeCh == AL) {
          subMode = ALPHA;
        }
         else if (subModeCh == PS) {
          priorToShiftMode = subMode;
          subMode = PUNCT_SHIFT;
        }
         else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
          [result append:(unichar)byteCompactionData[i]];
        }
      }
      break;
    case PUNCT:
      if (subModeCh < PAL) {
        ch = PUNCT_CHARS[subModeCh];
      }
       else {
        if (subModeCh == PAL) {
          subMode = ALPHA;
        }
         else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
          [result append:(unichar)byteCompactionData[i]];
        }
      }
      break;
    case ALPHA_SHIFT:
      subMode = priorToShiftMode;
      if (subModeCh < 26) {
        ch = (unichar)('A' + subModeCh);
      }
       else {
        if (subModeCh == 26) {
          ch = ' ';
        }
         else {
        }
      }
      break;
    case PUNCT_SHIFT:
      subMode = priorToShiftMode;
      if (subModeCh < PAL) {
        ch = PUNCT_CHARS[subModeCh];
      }
       else {
        if (subModeCh == PAL) {
          subMode = ALPHA;
        }
      }
      break;
    }
    if (ch != 0) {
      [result append:ch];
    }
    i++;
  }

}


/**
 * Byte Compaction mode (see 5.4.3) permits all 256 possible 8-bit byte values to be encoded.
 * This includes all ASCII characters value 0 to 127 inclusive and provides for international
 * character set support.
 * 
 * @param mode      The byte compaction mode i.e. 901 or 924
 * @param codewords The array of codewords (data + error)
 * @param codeIndex The current index into the codeword array.
 * @param result    The decoded data is appended to the result.
 * @return The next index into the codeword array.
 */
+ (int) byteCompaction:(int)mode codewords:(NSArray *)codewords codeIndex:(int)codeIndex result:(NSMutableString *)result {
  if (mode == BYTE_COMPACTION_MODE_LATCH) {
    int count = 0;
    long value = 0;
    NSArray * decodedData = [NSArray array];
    NSArray * byteCompactedCodewords = [NSArray array];
    BOOL end = NO;

    while ((codeIndex < codewords[0]) && !end) {
      int code = codewords[codeIndex++];
      if (code < TEXT_COMPACTION_MODE_LATCH) {
        byteCompactedCodewords[count] = code;
        count++;
        value = 900 * value + code;
      }
       else {
        if (code == TEXT_COMPACTION_MODE_LATCH || code == BYTE_COMPACTION_MODE_LATCH || code == NUMERIC_COMPACTION_MODE_LATCH || code == BYTE_COMPACTION_MODE_LATCH_6 || code == BEGIN_MACRO_PDF417_CONTROL_BLOCK || code == BEGIN_MACRO_PDF417_OPTIONAL_FIELD || code == MACRO_PDF417_TERMINATOR) {
          codeIndex--;
          end = YES;
        }
      }
      if ((count % 5 == 0) && (count > 0)) {

        for (int j = 0; j < 6; ++j) {
          decodedData[5 - j] = (unichar)(value % 256);
          value >>= 8;
        }

        [result append:decodedData];
        count = 0;
      }
    }


    for (int i = (count / 5) * 5; i < count; i++) {
      [result append:(unichar)byteCompactedCodewords[i]];
    }

  }
   else if (mode == BYTE_COMPACTION_MODE_LATCH_6) {
    int count = 0;
    long value = 0;
    BOOL end = NO;

    while (codeIndex < codewords[0] && !end) {
      int code = codewords[codeIndex++];
      if (code < TEXT_COMPACTION_MODE_LATCH) {
        count++;
        value = 900 * value + code;
      }
       else {
        if (code == TEXT_COMPACTION_MODE_LATCH || code == BYTE_COMPACTION_MODE_LATCH || code == NUMERIC_COMPACTION_MODE_LATCH || code == BYTE_COMPACTION_MODE_LATCH_6 || code == BEGIN_MACRO_PDF417_CONTROL_BLOCK || code == BEGIN_MACRO_PDF417_OPTIONAL_FIELD || code == MACRO_PDF417_TERMINATOR) {
          codeIndex--;
          end = YES;
        }
      }
      if ((count % 5 == 0) && (count > 0)) {
        NSArray * decodedData = [NSArray array];

        for (int j = 0; j < 6; ++j) {
          decodedData[5 - j] = (unichar)(value & 0xFF);
          value >>= 8;
        }

        [result append:decodedData];
      }
    }

  }
  return codeIndex;
}


/**
 * Numeric Compaction mode (see 5.4.4) permits efficient encoding of numeric data strings.
 * 
 * @param codewords The array of codewords (data + error)
 * @param codeIndex The current index into the codeword array.
 * @param result    The decoded data is appended to the result.
 * @return The next index into the codeword array.
 */
+ (int) numericCompaction:(NSArray *)codewords codeIndex:(int)codeIndex result:(NSMutableString *)result {
  int count = 0;
  BOOL end = NO;
  NSArray * numericCodewords = [NSArray array];

  while (codeIndex < codewords[0] && !end) {
    int code = codewords[codeIndex++];
    if (codeIndex == codewords[0]) {
      end = YES;
    }
    if (code < TEXT_COMPACTION_MODE_LATCH) {
      numericCodewords[count] = code;
      count++;
    }
     else {
      if (code == TEXT_COMPACTION_MODE_LATCH || code == BYTE_COMPACTION_MODE_LATCH || code == BYTE_COMPACTION_MODE_LATCH_6 || code == BEGIN_MACRO_PDF417_CONTROL_BLOCK || code == BEGIN_MACRO_PDF417_OPTIONAL_FIELD || code == MACRO_PDF417_TERMINATOR) {
        codeIndex--;
        end = YES;
      }
    }
    if (count % MAX_NUMERIC_CODEWORDS == 0 || code == NUMERIC_COMPACTION_MODE_LATCH || end) {
      NSString * s = [self decodeBase900toBase10:numericCodewords count:count];
      [result append:s];
      count = 0;
    }
  }

  return codeIndex;
}

+ (NSString *) decodeBase900toBase10:(NSArray *)codewords count:(int)count {
  NSMutableString * accum = nil;

  for (int i = 0; i < count; i++) {
    NSMutableString * value = [self multiply:EXP900[count - i - 1] value2:codewords[i]];
    if (accum == nil) {
      accum = value;
    }
     else {
      accum = [self add:[accum description] value2:[value description]];
    }
  }

  NSString * result = nil;

  for (int i = 0; i < [accum length]; i++) {
    if ([accum charAt:i] == '1') {
      result = [[accum description] substring:i + 1];
      break;
    }
  }

  if (result == nil) {
    result = [accum description];
  }
  return result;
}


/**
 * Multiplies two String numbers
 * 
 * @param value1 Any number represented as a string.
 * @param value2 A number <= 999.
 * @return the result of value1 * value2.
 */
+ (NSMutableString *) multiply:(NSString *)value1 value2:(int)value2 {
  NSMutableString * result = [[[NSMutableString alloc] init:[value1 length]] autorelease];

  for (int i = 0; i < [value1 length]; i++) {
    [result append:'0'];
  }

  int hundreds = value2 / 100;
  int tens = (value2 / 10) % 10;
  int ones = value2 % 10;

  for (int j = 0; j < ones; j++) {
    result = [self add:[result description] value2:value1];
  }


  for (int j = 0; j < tens; j++) {
    result = [self add:[result description] value2:[([value1 stringByAppendingString:'0']) substring:1]];
  }


  for (int j = 0; j < hundreds; j++) {
    result = [self add:[result description] value2:[([value1 stringByAppendingString:@"00"]) substring:2]];
  }

  return result;
}


/**
 * Add two numbers which are represented as strings.
 * 
 * @param value1
 * @param value2
 * @return the result of value1 + value2
 */
+ (NSMutableString *) add:(NSString *)value1 value2:(NSString *)value2 {
  NSMutableString * temp1 = [[[NSMutableString alloc] init:5] autorelease];
  NSMutableString * temp2 = [[[NSMutableString alloc] init:5] autorelease];
  NSMutableString * result = [[[NSMutableString alloc] init:[value1 length]] autorelease];

  for (int i = 0; i < [value1 length]; i++) {
    [result append:'0'];
  }

  int carry = 0;

  for (int i = [value1 length] - 3; i > -1; i -= 3) {
    [temp1 setLength:0];
    [temp1 append:[value1 characterAtIndex:i]];
    [temp1 append:[value1 characterAtIndex:i + 1]];
    [temp1 append:[value1 characterAtIndex:i + 2]];
    [temp2 setLength:0];
    [temp2 append:[value2 characterAtIndex:i]];
    [temp2 append:[value2 characterAtIndex:i + 1]];
    [temp2 append:[value2 characterAtIndex:i + 2]];
    int intValue1 = [Integer parseInt:[temp1 description]];
    int intValue2 = [Integer parseInt:[temp2 description]];
    int sumval = (intValue1 + intValue2 + carry) % 1000;
    carry = (intValue1 + intValue2 + carry) / 1000;
    [result setCharAt:i + 2 param1:(unichar)((sumval % 10) + '0')];
    [result setCharAt:i + 1 param1:(unichar)(((sumval / 10) % 10) + '0')];
    [result setCharAt:i param1:(unichar)((sumval / 100) + '0')];
  }

  return result;
}

@end

#import "DecoderResult.h"
#import "FormatException.h"
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

int const PDF417_ALPHA = 0;
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

char const PUNCT_CHARS[29] = {';', '<', '>', '@', '[', 92, '}', '_', 96, '~', '!',
  13, 9, ',', ':', 10, '-', '.', '$', '/', 34, '|', '*',
  '(', ')', '?', '{', '}', 39};

char const MIXED_CHARS[25] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '&',
  13, 9, ',', ':', '#', '-', '.', '$', '/', '+', '%', '*',
  '=', '^'};

// Table containing values for the exponent of 900.
// This is used in the numeric compaction decode algorithm.
NSString* const EXP900[16] =
  {   @"000000000000000000000000000000000000000000001",
      @"000000000000000000000000000000000000000000900",
      @"000000000000000000000000000000000000000810000",
      @"000000000000000000000000000000000000729000000",
      @"000000000000000000000000000000000656100000000",
      @"000000000000000000000000000000590490000000000",
      @"000000000000000000000000000531441000000000000",
      @"000000000000000000000000478296900000000000000",
      @"000000000000000000000430467210000000000000000",
      @"000000000000000000387420489000000000000000000",
      @"000000000000000348678440100000000000000000000",
      @"000000000000313810596090000000000000000000000",
      @"000000000282429536481000000000000000000000000",
      @"000000254186582832900000000000000000000000000",
      @"000228767924549610000000000000000000000000000",
      @"205891132094649000000000000000000000000000000"};

@interface PDF417DecodedBitStreamParser ()

+ (NSMutableString *) add:(NSString *)value1 value2:(NSString *)value2;
+ (int) byteCompaction:(int)mode codewords:(NSArray *)codewords codeIndex:(int)codeIndex result:(NSMutableString *)result;
+ (NSString *) decodeBase900toBase10:(int[])codewords count:(int)count;
+ (void) decodeTextCompaction:(int[])textCompactionData byteCompactionData:(int[])byteCompactionData length:(unsigned int)length result:(NSMutableString *)result;
+ (NSMutableString *) multiply:(NSString *)value1 value2:(int)value2;
+ (int) numericCompaction:(NSArray *)codewords codeIndex:(int)codeIndex result:(NSMutableString *)result;
+ (int) textCompaction:(NSArray *)codewords codeIndex:(int)codeIndex result:(NSMutableString *)result;

@end

@implementation PDF417DecodedBitStreamParser

+ (DecoderResult *) decode:(NSArray *)codewords {
  NSMutableString * result = [NSMutableString stringWithCapacity:100];
  int codeIndex = 1;
  int code = [[codewords objectAtIndex:codeIndex++] intValue];
  while (codeIndex < [[codewords objectAtIndex:0] intValue]) {
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
    if (codeIndex < [codewords count]) {
      code = [[codewords objectAtIndex:codeIndex++] intValue];
    } else {
      @throw [FormatException formatInstance];
    }
  }
  return [[[DecoderResult alloc] init:nil length:0 text:result byteSegments:nil ecLevel:nil] autorelease];
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
  int textCompactionData[[[codewords objectAtIndex:0] intValue] << 1];
  int byteCompactionData[[[codewords objectAtIndex:0] intValue] << 1];

  int index = 0;
  BOOL end = NO;
  while ((codeIndex < [[codewords objectAtIndex:0] intValue]) && !end) {
    int code = [[codewords objectAtIndex:codeIndex++] intValue];
    if (code < TEXT_COMPACTION_MODE_LATCH) {
      textCompactionData[index] = code / 30;
      textCompactionData[index + 1] = code % 30;
      index += 2;
    } else {
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
        code = [[codewords objectAtIndex:codeIndex++] intValue];
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
+ (void) decodeTextCompaction:(int[])textCompactionData byteCompactionData:(int[])byteCompactionData length:(unsigned int)length result:(NSMutableString *)result {
  int subMode = PDF417_ALPHA;
  int priorToShiftMode = PDF417_ALPHA;
  int i = 0;
  while (i < length) {
    int subModeCh = textCompactionData[i];
    unichar ch = 0;
    switch (subMode) {
    case PDF417_ALPHA:
      if (subModeCh < 26) {
        ch = (unichar)('A' + subModeCh);
      } else {
        if (subModeCh == 26) {
          ch = ' ';
        } else if (subModeCh == LL) {
          subMode = LOWER;
        } else if (subModeCh == ML) {
          subMode = MIXED;
        } else if (subModeCh == PS) {
          priorToShiftMode = subMode;
          subMode = PUNCT_SHIFT;
        } else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
          [result appendFormat:@"%C", (unichar)byteCompactionData[i]];
        }
      }
      break;
    case LOWER:
      if (subModeCh < 26) {
        ch = (unichar)('a' + subModeCh);
      } else {
        if (subModeCh == 26) {
          ch = ' ';
        } else if (subModeCh == AS) {
          priorToShiftMode = subMode;
          subMode = ALPHA_SHIFT;
        } else if (subModeCh == ML) {
          subMode = MIXED;
        } else if (subModeCh == PS) {
          priorToShiftMode = subMode;
          subMode = PUNCT_SHIFT;
        } else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
          [result appendFormat:@"%C", (unichar)byteCompactionData[i]];
        }
      }
      break;
    case MIXED:
      if (subModeCh < PL) {
        ch = MIXED_CHARS[subModeCh];
      } else {
        if (subModeCh == PL) {
          subMode = PUNCT;
        } else if (subModeCh == 26) {
          ch = ' ';
        } else if (subModeCh == LL) {
          subMode = LOWER;
        } else if (subModeCh == AL) {
          subMode = PDF417_ALPHA;
        } else if (subModeCh == PS) {
          priorToShiftMode = subMode;
          subMode = PUNCT_SHIFT;
        } else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
          [result appendFormat:@"%C", (unichar)byteCompactionData[i]];
        }
      }
      break;
    case PUNCT:
      if (subModeCh < PAL) {
        ch = PUNCT_CHARS[subModeCh];
      } else {
        if (subModeCh == PAL) {
          subMode = PDF417_ALPHA;
        } else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
          [result appendFormat:@"%C", (unichar)byteCompactionData[i]];
        }
      }
      break;
    case ALPHA_SHIFT:
      subMode = priorToShiftMode;
      if (subModeCh < 26) {
        ch = (unichar)('A' + subModeCh);
      } else {
        if (subModeCh == 26) {
          ch = ' ';
        } else {
        }
      }
      break;
    case PUNCT_SHIFT:
      subMode = priorToShiftMode;
      if (subModeCh < PAL) {
        ch = PUNCT_CHARS[subModeCh];
      } else {
        if (subModeCh == PAL) {
          subMode = PDF417_ALPHA;
        }
      }
      break;
    }
    if (ch != 0) {
      [result appendFormat:@"%C", ch];
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
    NSMutableString * decodedData = [NSMutableString stringWithCapacity:6];
    int byteCompactedCodewords[6];
    BOOL end = NO;
    while ((codeIndex < [[codewords objectAtIndex:0] intValue]) && !end) {
      int code = [[codewords objectAtIndex:codeIndex++] intValue];
      if (code < TEXT_COMPACTION_MODE_LATCH) {
        byteCompactedCodewords[count] = code;
        count++;
        value = 900 * value + code;
      } else {
        if (code == TEXT_COMPACTION_MODE_LATCH ||
            code == BYTE_COMPACTION_MODE_LATCH ||
            code == NUMERIC_COMPACTION_MODE_LATCH ||
            code == BYTE_COMPACTION_MODE_LATCH_6 ||
            code == BEGIN_MACRO_PDF417_CONTROL_BLOCK ||
            code == BEGIN_MACRO_PDF417_OPTIONAL_FIELD ||
            code == MACRO_PDF417_TERMINATOR) {
          codeIndex--;
          end = YES;
        }
      }
      if ((count % 5 == 0) && (count > 0)) {
        for (int j = 0; j < 6; ++j) {
          [decodedData replaceCharactersInRange:NSMakeRange(5-j, 1) withString:[NSString stringWithFormat:@"%C", (unichar)(value % 256)]];
          value >>= 8;
        }
        [result appendString:decodedData];
        count = 0;
      }
    }

    for (int i = (count / 5) * 5; i < count; i++) {
      [result appendFormat:@"%C", (unichar)byteCompactedCodewords[i]];
    }
  } else if (mode == BYTE_COMPACTION_MODE_LATCH_6) {
    int count = 0;
    long value = 0;
    BOOL end = NO;
    while (codeIndex < [[codewords objectAtIndex:0] intValue] && !end) {
      int code = [[codewords objectAtIndex:codeIndex++] intValue];
      if (code < TEXT_COMPACTION_MODE_LATCH) {
        count++;
        value = 900 * value + code;
      } else {
        if (code == TEXT_COMPACTION_MODE_LATCH ||
            code == BYTE_COMPACTION_MODE_LATCH ||
            code == NUMERIC_COMPACTION_MODE_LATCH ||
            code == BYTE_COMPACTION_MODE_LATCH_6 ||
            code == BEGIN_MACRO_PDF417_CONTROL_BLOCK ||
            code == BEGIN_MACRO_PDF417_OPTIONAL_FIELD ||
            code == MACRO_PDF417_TERMINATOR) {
          codeIndex--;
          end = YES;
        }
      }
      if ((count % 5 == 0) && (count > 0)) {
        NSMutableString *decodedData = [NSMutableString stringWithCapacity:6];
        for (int j = 0; j < 6; ++j) {
          [decodedData replaceCharactersInRange:NSMakeRange(5-j, 1) withString:[NSString stringWithFormat:@"%C", (unichar)(value & 0xFF)]];
          value >>= 8;
        }
        [result appendString:decodedData];
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

  int numericCodewords[MAX_NUMERIC_CODEWORDS];

  while (codeIndex < [[codewords objectAtIndex:0] intValue] && !end) {
    int code = [[codewords objectAtIndex:codeIndex++] intValue];
    if (codeIndex == [[codewords objectAtIndex:0] intValue]) {
      end = YES;
    }
    if (code < TEXT_COMPACTION_MODE_LATCH) {
      numericCodewords[count] = code;
      count++;
    } else {
      if (code == TEXT_COMPACTION_MODE_LATCH ||
          code == BYTE_COMPACTION_MODE_LATCH ||
          code == BYTE_COMPACTION_MODE_LATCH_6 ||
          code == BEGIN_MACRO_PDF417_CONTROL_BLOCK ||
          code == BEGIN_MACRO_PDF417_OPTIONAL_FIELD ||
          code == MACRO_PDF417_TERMINATOR) {
        codeIndex--;
        end = YES;
      }
    }
    if (count % MAX_NUMERIC_CODEWORDS == 0 || code == NUMERIC_COMPACTION_MODE_LATCH || end) {
      NSString * s = [self decodeBase900toBase10:numericCodewords count:count];
      [result appendString:s];
      count = 0;
    }
  }
  return codeIndex;
}

/**
 * Convert a list of Numeric Compacted codewords from Base 900 to Base 10.
 *
 * @param codewords The array of codewords
 * @param count     The number of codewords
 * @return The decoded string representing the Numeric data.
 */
/*
   EXAMPLE
   Encode the fifteen digit numeric string 000213298174000
   Prefix the numeric string with a 1 and set the initial value of
   t = 1 000 213 298 174 000
   Calculate codeword 0
   d0 = 1 000 213 298 174 000 mod 900 = 200
   
   t = 1 000 213 298 174 000 div 900 = 1 111 348 109 082
   Calculate codeword 1
   d1 = 1 111 348 109 082 mod 900 = 282
   
   t = 1 111 348 109 082 div 900 = 1 234 831 232
   Calculate codeword 2
   d2 = 1 234 831 232 mod 900 = 632
   
   t = 1 234 831 232 div 900 = 1 372 034
   Calculate codeword 3
   d3 = 1 372 034 mod 900 = 434
   
   t = 1 372 034 div 900 = 1 524
   Calculate codeword 4
   d4 = 1 524 mod 900 = 624
   
   t = 1 524 div 900 = 1
   Calculate codeword 5
   d5 = 1 mod 900 = 1
   t = 1 div 900 = 0
   Codeword sequence is: 1, 624, 434, 632, 282, 200
   
   Decode the above codewords involves
   1 x 900 power of 5 + 624 x 900 power of 4 + 434 x 900 power of 3 +
   632 x 900 power of 2 + 282 x 900 power of 1 + 200 x 900 power of 0 = 1000213298174000
   
   Remove leading 1 =>  Result is 000213298174000
   
   As there are huge numbers involved here we must use fake out the maths using string
   tokens for the numbers.
   BigDecimal is not supported by J2ME.
 */
+ (NSString *) decodeBase900toBase10:(int[])codewords count:(int)count {
  NSMutableString * accum = nil;
  for (int i = 0; i < count; i++) {
    NSMutableString * value = [self multiply:EXP900[count - i - 1] value2:codewords[i]];
    if (accum == nil) {
      accum = value;
    } else {
      accum = [self add:accum value2:value];
    }
  }

  NSString * result = nil;

  for (int i = 0; i < [accum length]; i++) {
    if ([accum characterAtIndex:i] == '1') {
      result = [accum substringFromIndex:i + 1];
      break;
    }
  }
  if (result == nil) {
    result = accum;
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
  NSMutableString * result = [NSMutableString stringWithCapacity:[value1 length]];
  for (int i = 0; i < [value1 length]; i++) {
    [result appendString:@"0"];
  }
  int hundreds = value2 / 100;
  int tens = (value2 / 10) % 10;
  int ones = value2 % 10;

  for (int j = 0; j < ones; j++) {
    result = [self add:result value2:value1];
  }

  for (int j = 0; j < tens; j++) {
    result = [self add:result value2:[[NSString stringWithFormat:@"0%@", value1] substringFromIndex:1]];
  }

  for (int j = 0; j < hundreds; j++) {
    result = [self add:result value2:[[NSString stringWithFormat:@"00%@", value1] substringFromIndex:2]];
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
  NSMutableString * temp1 = [NSMutableString stringWithCapacity:5];
  NSMutableString * temp2 = [NSMutableString stringWithCapacity:5];
  NSMutableString * result = [NSMutableString stringWithCapacity:[value1 length]];
  for (int i = 0; i < [value1 length]; i++) {
    [result appendString:@"0"];
  }
  int carry = 0;
  for (int i = [value1 length] - 3; i > -1; i -= 3) {
    [temp1 deleteCharactersInRange:NSMakeRange(0, [temp1 length])];
    [temp1 appendString:[value1 substringWithRange:NSMakeRange(i, 1)]];
    [temp1 appendString:[value1 substringWithRange:NSMakeRange(i + 1, 1)]];
    [temp1 appendString:[value1 substringWithRange:NSMakeRange(i + 2, 1)]];

    [temp2 deleteCharactersInRange:NSMakeRange(0, [temp2 length])];
    [temp2 appendString:[value2 substringWithRange:NSMakeRange(i, 1)]];
    [temp2 appendString:[value2 substringWithRange:NSMakeRange(i + 1, 1)]];
    [temp2 appendString:[value2 substringWithRange:NSMakeRange(i + 2, 1)]];

    int intValue1 = [temp1 intValue];
    int intValue2 = [temp2 intValue];

    int sumval = (intValue1 + intValue2 + carry) % 1000;
    carry = (intValue1 + intValue2 + carry) / 1000;

    [result replaceCharactersInRange:NSMakeRange(i + 2, 1) withString:[NSString stringWithFormat:@"%C", (unichar)((sumval % 10) + '0')]];
    [result replaceCharactersInRange:NSMakeRange(i + 1, 1) withString:[NSString stringWithFormat:@"%C", (unichar)(((sumval / 10) % 10) + '0')]];
    [result replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithFormat:@"%C", (unichar)((sumval / 100) + '0')]];
  }

  return result;
}

@end

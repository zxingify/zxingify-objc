#import "ZXBitSource.h"
#import "ZXDataMatrixDecodedBitStreamParser.h"
#import "ZXDecoderResult.h"
#import "ZXFormatException.h"

/**
 * See ISO 16022:2006, Annex C Table C.1
 * The C40 Basic Character Set (*'s used for placeholders for the shift values)
 */
const char C40_BASIC_SET_CHARS[40] = {
  '*', '*', '*', ' ', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
  'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
};

const char C40_SHIFT2_SET_CHARS[40] = {
  '!', '"', '#', '$', '%', '&', '\'', '(', ')', '*',  '+', ',', '-', '.',
  '/', ':', ';', '<', '=', '>', '?',  '@', '[', '\\', ']', '^', '_'
};

/**
 * See ISO 16022:2006, Annex C Table C.2
 * The Text Basic Character Set (*'s used for placeholders for the shift values)
 */
const char TEXT_BASIC_SET_CHARS[40] = {
  '*', '*', '*', ' ', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
  'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
};

const char TEXT_SHIFT3_SET_CHARS[32] = {
  '\'', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
  'O',  'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '{', '|', '}', '~', (char) 127
};

const int PAD_ENCODE = 0;
const int ASCII_ENCODE = 1;
const int C40_ENCODE = 2;
const int TEXT_ENCODE = 3;
const int ANSIX12_ENCODE = 4;
const int EDIFACT_ENCODE = 5;
const int BASE256_ENCODE = 6;

@interface ZXDataMatrixDecodedBitStreamParser ()

+ (void) decodeAnsiX12Segment:(ZXBitSource *)bits result:(NSMutableString *)result;
+ (int) decodeAsciiSegment:(ZXBitSource *)bits result:(NSMutableString *)result resultTrailer:(NSMutableString *)resultTrailer;
+ (void) decodeBase256Segment:(ZXBitSource *)bits result:(NSMutableString *)result byteSegments:(NSMutableArray *)byteSegments;
+ (void) decodeC40Segment:(ZXBitSource *)bits result:(NSMutableString *)result;
+ (void) decodeEdifactSegment:(ZXBitSource *)bits result:(NSMutableString *)result;
+ (void) decodeTextSegment:(ZXBitSource *)bits result:(NSMutableString *)result;
+ (void) parseTwoBytes:(int)firstByte secondByte:(int)secondByte result:(int[])result;
+ (char) unrandomize255State:(int)randomizedBase256Codeword base256CodewordPosition:(int)base256CodewordPosition;

@end

@implementation ZXDataMatrixDecodedBitStreamParser

+ (ZXDecoderResult *) decode:(unsigned char *)bytes length:(unsigned int)length {
  ZXBitSource * bits = [[[ZXBitSource alloc] initWithBytes:bytes length:length] autorelease];
  NSMutableString * result = [NSMutableString stringWithCapacity:100];
  NSMutableString * resultTrailer = [NSMutableString string];
  NSMutableArray * byteSegments = [NSMutableArray arrayWithCapacity:1];
  int mode = ASCII_ENCODE;
  do {
    if (mode == ASCII_ENCODE) {
      mode = [self decodeAsciiSegment:bits result:result resultTrailer:resultTrailer];
    } else {
      switch (mode) {
      case C40_ENCODE:
        [self decodeC40Segment:bits result:result];
        break;
      case TEXT_ENCODE:
        [self decodeTextSegment:bits result:result];
        break;
      case ANSIX12_ENCODE:
        [self decodeAnsiX12Segment:bits result:result];
        break;
      case EDIFACT_ENCODE:
        [self decodeEdifactSegment:bits result:result];
        break;
      case BASE256_ENCODE:
        [self decodeBase256Segment:bits result:result byteSegments:byteSegments];
        break;
      default:
        @throw [ZXFormatException formatInstance];
      }
      mode = ASCII_ENCODE;
    }
  }
   while (mode != PAD_ENCODE && [bits available] > 0);
  if ([resultTrailer length] > 0) {
    [result appendString:resultTrailer];
  }
  return [[[ZXDecoderResult alloc] initWithRawBytes:bytes
                                             length:length
                                               text:result
                                       byteSegments:[byteSegments count] == 0 ? nil : byteSegments
                                            ecLevel:nil] autorelease];
}


/**
 * See ISO 16022:2006, 5.2.3 and Annex C, Table C.2
 */
+ (int) decodeAsciiSegment:(ZXBitSource *)bits result:(NSMutableString *)result resultTrailer:(NSMutableString *)resultTrailer {
  BOOL upperShift = NO;

  do {
    int oneByte = [bits readBits:8];
    if (oneByte == 0) {
      @throw [ZXFormatException formatInstance];
    } else if (oneByte <= 128) {
      oneByte = upperShift ? oneByte + 128 : oneByte;
      upperShift = NO;
      [result appendFormat:@"%C", (unichar)(oneByte - 1)];
      return ASCII_ENCODE;
    } else if (oneByte == 129) {
      return PAD_ENCODE;
    } else if (oneByte <= 229) {
      int value = oneByte - 130;
      if (value < 10) {
        [result appendString:@"0"];
      }
      [result appendFormat:@"%d", value];
    } else if (oneByte == 230) {
      return C40_ENCODE;
    } else if (oneByte == 231) {
      return BASE256_ENCODE;
    } else if (oneByte == 232 || oneByte == 233 || oneByte == 234) {
      // FNC1, Structured Append, Reader Programming
      // Ignore these symbols for now
    } else if (oneByte == 235) {
      upperShift = YES;
    } else if (oneByte == 236) {
      [result appendFormat:@"[)>%C%C", 0x001E05, 0x001D];
      [resultTrailer insertString:[NSString stringWithFormat:@"%C%C", 0x001E, 0x0004] atIndex:0];
    } else if (oneByte == 237) {
      [result appendFormat:@"[)>%C%C", 0x001E06, 0x001D];
      [resultTrailer insertString:[NSString stringWithFormat:@"%C%C", 0x001E, 0x0004] atIndex:0];
    } else if (oneByte == 238) {
      return ANSIX12_ENCODE;
    } else if (oneByte == 239) {
      return TEXT_ENCODE;
    } else if (oneByte == 240) {
      return EDIFACT_ENCODE;
    } else if (oneByte == 241) {
      // TODO(bbrown): I think we need to support ECI
      // Ignore this symbol for now
    } else if (oneByte >= 242) {
      if (oneByte == 254 && [bits available] == 0) {
        // Ignore
      } else {
        @throw [ZXFormatException formatInstance];
      }
    }
  } while ([bits available] > 0);
  return ASCII_ENCODE;
}


/**
 * See ISO 16022:2006, 5.2.5 and Annex C, Table C.1
 */
+ (void) decodeC40Segment:(ZXBitSource *)bits result:(NSMutableString *)result {
  BOOL upperShift = NO;

  int cValues[3];
  do {
    if ([bits available] == 8) {
      return;
    }
    int firstByte = [bits readBits:8];
    if (firstByte == 254) {
      return;
    }

    [self parseTwoBytes:firstByte secondByte:[bits readBits:8] result:cValues];

    int shift = 0;
    for (int i = 0; i < 3; i++) {
      int cValue = cValues[i];
      switch (shift) {
      case 0:
        if (cValue < 3) {
          shift = cValue + 1;
        } else if (cValue < sizeof(C40_BASIC_SET_CHARS) / sizeof(char)) {
          unichar c40char = C40_BASIC_SET_CHARS[cValue];
          if (upperShift) {
            [result appendFormat:@"%C", (unichar)(c40char + 128)];
            upperShift = NO;
          } else {
            [result appendFormat:@"%C", c40char];
          }
        } else {
          @throw [ZXFormatException formatInstance];
        }
        break;
      case 1:
        if (upperShift) {
          [result appendFormat:@"%C", (unichar)(cValue + 128)];
          upperShift = NO;
        } else {
          [result appendFormat:@"%C", cValue];
        }
        shift = 0;
        break;
      case 2:
        if (cValue < sizeof(C40_SHIFT2_SET_CHARS) / sizeof(char)) {
          unichar c40char = C40_SHIFT2_SET_CHARS[cValue];
          if (upperShift) {
            [result appendFormat:@"%C", (unichar)(c40char + 128)];
            upperShift = NO;
          } else {
            [result appendFormat:@"%C", c40char];
          }
        } else if (cValue == 27) {
          @throw [ZXFormatException formatInstance];
        } else if (cValue == 30) {
          upperShift = YES;
        } else {
          @throw [ZXFormatException formatInstance];
        }
        shift = 0;
        break;
      case 3:
        if (upperShift) {
          [result appendFormat:@"%C", (unichar)(cValue + 224)];
          upperShift = NO;
        } else {
          [result appendFormat:@"%C", (unichar)(cValue + 96)];
        }
        shift = 0;
        break;
      default:
        @throw [ZXFormatException formatInstance];
      }
    }
  } while ([bits available] > 0);
}


/**
 * See ISO 16022:2006, 5.2.6 and Annex C, Table C.2
 */
+ (void) decodeTextSegment:(ZXBitSource *)bits result:(NSMutableString *)result {
  BOOL upperShift = NO;

  int cValues[3];
  int shift = 0;
  do {
    if ([bits available] == 8) {
      return;
    }
    int firstByte = [bits readBits:8];
    if (firstByte == 254) {
      return;
    }

    [self parseTwoBytes:firstByte secondByte:[bits readBits:8] result:cValues];

    for (int i = 0; i < 3; i++) {
      int cValue = cValues[i];
      switch (shift) {
      case 0:
        if (cValue < 3) {
          shift = cValue + 1;
        } else if (cValue < sizeof(TEXT_BASIC_SET_CHARS) / sizeof(char)) {
          unichar textChar = TEXT_BASIC_SET_CHARS[cValue];
          if (upperShift) {
            [result appendFormat:@"%C", (unichar)(textChar + 128)];
            upperShift = NO;
          } else {
            [result appendFormat:@"%C", textChar];
          }
        } else {
          @throw [ZXFormatException formatInstance];
        }
        break;
      case 1:
        if (upperShift) {
          [result appendFormat:@"%C", (unichar)(cValue + 128)];
          upperShift = NO;
        } else {
          [result appendFormat:@"%C", cValue];
        }
        shift = 0;
        break;
      case 2:
        if (cValue < sizeof(C40_SHIFT2_SET_CHARS) / sizeof(char)) {
          unichar c40char = C40_SHIFT2_SET_CHARS[cValue];
          if (upperShift) {
            [result appendFormat:@"%C", (unichar)(c40char + 128)];
            upperShift = NO;
          } else {
            [result appendFormat:@"%C", c40char];
          }
        } else if (cValue == 27) {
          @throw [ZXFormatException formatInstance];
        } else if (cValue == 30) {
          upperShift = YES;
        } else {
          @throw [ZXFormatException formatInstance];
        }
        shift = 0;
        break;
      case 3:
        if (cValue < sizeof(TEXT_SHIFT3_SET_CHARS) / sizeof(char)) {
          unichar textChar = TEXT_SHIFT3_SET_CHARS[cValue];
          if (upperShift) {
            [result appendFormat:@"%C", (unichar)(textChar + 128)];
            upperShift = NO;
          } else {
            [result appendFormat:@"%C", textChar];
          }
          shift = 0;
        } else {
          @throw [ZXFormatException formatInstance];
        }
        break;
      default:
        @throw [ZXFormatException formatInstance];
      }
    }
  } while ([bits available] > 0);
}


/**
 * See ISO 16022:2006, 5.2.7
 */
+ (void) decodeAnsiX12Segment:(ZXBitSource *)bits result:(NSMutableString *)result {
  int cValues[3];
  do {
    if ([bits available] == 8) {
      return;
    }
    int firstByte = [bits readBits:8];
    if (firstByte == 254) {
      return;
    }
    [self parseTwoBytes:firstByte secondByte:[bits readBits:8] result:cValues];

    for (int i = 0; i < 3; i++) {
      int cValue = cValues[i];
      if (cValue == 0) {
        [result appendString:@"\r"];
      } else if (cValue == 1) {
        [result appendString:@"*"];
      } else if (cValue == 2) {
        [result appendString:@">"];
      } else if (cValue == 3) {
        [result appendString:@" "];
      } else if (cValue < 14) {
        [result appendFormat:@"%C", (unichar)(cValue + 44)];
      } else if (cValue < 40) {
        [result appendFormat:@"%C", (unichar)(cValue + 51)];
      } else {
        @throw [ZXFormatException formatInstance];
      }
    }
  } while ([bits available] > 0);
}

+ (void) parseTwoBytes:(int)firstByte secondByte:(int)secondByte result:(int[])result {
  int fullBitValue = (firstByte << 8) + secondByte - 1;
  int temp = fullBitValue / 1600;
  result[0] = temp;
  fullBitValue -= temp * 1600;
  temp = fullBitValue / 40;
  result[1] = temp;
  result[2] = fullBitValue - temp * 40;
}


/**
 * See ISO 16022:2006, 5.2.8 and Annex C Table C.3
 */
+ (void) decodeEdifactSegment:(ZXBitSource *)bits result:(NSMutableString *)result {
  BOOL unlatch = NO;

  do {
    if ([bits available] <= 16) {
      return;
    }

    for (int i = 0; i < 4; i++) {
      int edifactValue = [bits readBits:6];
      if (edifactValue == 0x1F) {
        unlatch = YES;
      }
      if (!unlatch) {
        if ((edifactValue & 32) == 0) {
          edifactValue |= 64;
        }
        [result appendFormat:@"%d", edifactValue];
      }
    }
  } while (!unlatch && [bits available] > 0);
}


/**
 * See ISO 16022:2006, 5.2.9 and Annex B, B.2
 */
+ (void) decodeBase256Segment:(ZXBitSource *)bits result:(NSMutableString *)result byteSegments:(NSMutableArray *)byteSegments {
  int codewordPosition = 2;
  int d1 = [self unrandomize255State:[bits readBits:8] base256CodewordPosition:codewordPosition++];
  int count;
  if (d1 == 0) {
    count = [bits available] / 8;
  } else if (d1 < 250) {
    count = d1;
  } else {
    count = 250 * (d1 - 249) + [self unrandomize255State:[bits readBits:8] base256CodewordPosition:codewordPosition++];
  }

  if (count < 0) {
    @throw [ZXFormatException formatInstance];
  }

  NSMutableArray * bytes = [NSMutableArray arrayWithCapacity:count];
  NSMutableData * data = [NSMutableData dataWithLength:count];
  for (int i = 0; i < count; i++) {
    if ([bits available] < 8) {
      @throw [ZXFormatException formatInstance];
    }
    char byte = [self unrandomize255State:[bits readBits:8] base256CodewordPosition:codewordPosition++];
    [bytes addObject:[NSNumber numberWithChar:byte]];
    [data appendBytes:&byte length:sizeof(char)];
  }
  [byteSegments addObject:bytes];

  [result appendString:[[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] autorelease]];
}


/**
 * See ISO 16022:2006, Annex B, B.2
 */
+ (char) unrandomize255State:(int)randomizedBase256Codeword base256CodewordPosition:(int)base256CodewordPosition {
  int pseudoRandomNumber = ((149 * base256CodewordPosition) % 255) + 1;
  int tempVariable = randomizedBase256Codeword - pseudoRandomNumber;
  return (char)(tempVariable >= 0 ? tempVariable : tempVariable + 256);
}

@end

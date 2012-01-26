#import "DecodedBitStreamParser.h"


/**
 * See ISO 16022:2006, Annex C Table C.1
 * The C40 Basic Character Set (*'s used for placeholders for the shift values)
 */
NSArray * const C40_BASIC_SET_CHARS = [NSArray arrayWithObjects:'*', '*', '*', ' ', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', nil];
NSArray * const C40_SHIFT2_SET_CHARS = [NSArray arrayWithObjects:'!', '"', '#', '$', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '.', '/', ':', ';', '<', '=', '>', '?', '@', '[', '\\', ']', '^', '_', nil];

/**
 * See ISO 16022:2006, Annex C Table C.2
 * The Text Basic Character Set (*'s used for placeholders for the shift values)
 */
NSArray * const TEXT_BASIC_SET_CHARS = [NSArray arrayWithObjects:'*', '*', '*', ' ', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', nil];
NSArray * const TEXT_SHIFT3_SET_CHARS = [NSArray arrayWithObjects:'\'', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '{', '|', '}', '~', (unichar)127, nil];
int const PAD_ENCODE = 0;
int const ASCII_ENCODE = 1;
int const C40_ENCODE = 2;
int const TEXT_ENCODE = 3;
int const ANSIX12_ENCODE = 4;
int const EDIFACT_ENCODE = 5;
int const BASE256_ENCODE = 6;

@implementation DecodedBitStreamParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (DecoderResult *) decode:(NSArray *)bytes {
  BitSource * bits = [[[BitSource alloc] init:bytes] autorelease];
  StringBuffer * result = [[[StringBuffer alloc] init:100] autorelease];
  StringBuffer * resultTrailer = [[[StringBuffer alloc] init:0] autorelease];
  NSMutableArray * byteSegments = [[[NSMutableArray alloc] init:1] autorelease];
  int mode = ASCII_ENCODE;

  do {
    if (mode == ASCII_ENCODE) {
      mode = [self decodeAsciiSegment:bits result:result resultTrailer:resultTrailer];
    }
     else {

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
        @throw [FormatException formatInstance];
      }
      mode = ASCII_ENCODE;
    }
  }
   while (mode != PAD_ENCODE && [bits available] > 0);
  if ([resultTrailer length] > 0) {
    [result append:[resultTrailer description]];
  }
  return [[[DecoderResult alloc] init:bytes param1:[result description] param2:[byteSegments empty] ? nil : byteSegments param3:nil] autorelease];
}


/**
 * See ISO 16022:2006, 5.2.3 and Annex C, Table C.2
 */
+ (int) decodeAsciiSegment:(BitSource *)bits result:(StringBuffer *)result resultTrailer:(StringBuffer *)resultTrailer {
  BOOL upperShift = NO;

  do {
    int oneByte = [bits readBits:8];
    if (oneByte == 0) {
      @throw [FormatException formatInstance];
    }
     else if (oneByte <= 128) {
      oneByte = upperShift ? oneByte + 128 : oneByte;
      upperShift = NO;
      [result append:(unichar)(oneByte - 1)];
      return ASCII_ENCODE;
    }
     else if (oneByte == 129) {
      return PAD_ENCODE;
    }
     else if (oneByte <= 229) {
      int value = oneByte - 130;
      if (value < 10) {
        [result append:'0'];
      }
      [result append:value];
    }
     else if (oneByte == 230) {
      return C40_ENCODE;
    }
     else if (oneByte == 231) {
      return BASE256_ENCODE;
    }
     else if (oneByte == 232 || oneByte == 233 || oneByte == 234) {
    }
     else if (oneByte == 235) {
      upperShift = YES;
    }
     else if (oneByte == 236) {
      [result append:@"[)>05"];
      [resultTrailer insert:0 param1:@""];
    }
     else if (oneByte == 237) {
      [result append:@"[)>06"];
      [resultTrailer insert:0 param1:@""];
    }
     else if (oneByte == 238) {
      return ANSIX12_ENCODE;
    }
     else if (oneByte == 239) {
      return TEXT_ENCODE;
    }
     else if (oneByte == 240) {
      return EDIFACT_ENCODE;
    }
     else if (oneByte == 241) {
    }
     else if (oneByte >= 242) {
      if (oneByte == 254 && [bits available] == 0) {
      }
       else {
        @throw [FormatException formatInstance];
      }
    }
  }
   while ([bits available] > 0);
  return ASCII_ENCODE;
}


/**
 * See ISO 16022:2006, 5.2.5 and Annex C, Table C.1
 */
+ (void) decodeC40Segment:(BitSource *)bits result:(StringBuffer *)result {
  BOOL upperShift = NO;
  NSArray * cValues = [NSArray array];

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
        }
         else if (cValue < C40_BASIC_SET_CHARS.length) {
          unichar c40char = C40_BASIC_SET_CHARS[cValue];
          if (upperShift) {
            [result append:(unichar)(c40char + 128)];
            upperShift = NO;
          }
           else {
            [result append:c40char];
          }
        }
         else {
          @throw [FormatException formatInstance];
        }
        break;
      case 1:
        if (upperShift) {
          [result append:(unichar)(cValue + 128)];
          upperShift = NO;
        }
         else {
          [result append:cValue];
        }
        shift = 0;
        break;
      case 2:
        if (cValue < C40_SHIFT2_SET_CHARS.length) {
          unichar c40char = C40_SHIFT2_SET_CHARS[cValue];
          if (upperShift) {
            [result append:(unichar)(c40char + 128)];
            upperShift = NO;
          }
           else {
            [result append:c40char];
          }
        }
         else if (cValue == 27) {
          @throw [FormatException formatInstance];
        }
         else if (cValue == 30) {
          upperShift = YES;
        }
         else {
          @throw [FormatException formatInstance];
        }
        shift = 0;
        break;
      case 3:
        if (upperShift) {
          [result append:(unichar)(cValue + 224)];
          upperShift = NO;
        }
         else {
          [result append:(unichar)(cValue + 96)];
        }
        shift = 0;
        break;
      default:
        @throw [FormatException formatInstance];
      }
    }

  }
   while ([bits available] > 0);
}


/**
 * See ISO 16022:2006, 5.2.6 and Annex C, Table C.2
 */
+ (void) decodeTextSegment:(BitSource *)bits result:(StringBuffer *)result {
  BOOL upperShift = NO;
  NSArray * cValues = [NSArray array];
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
        }
         else if (cValue < TEXT_BASIC_SET_CHARS.length) {
          unichar textChar = TEXT_BASIC_SET_CHARS[cValue];
          if (upperShift) {
            [result append:(unichar)(textChar + 128)];
            upperShift = NO;
          }
           else {
            [result append:textChar];
          }
        }
         else {
          @throw [FormatException formatInstance];
        }
        break;
      case 1:
        if (upperShift) {
          [result append:(unichar)(cValue + 128)];
          upperShift = NO;
        }
         else {
          [result append:cValue];
        }
        shift = 0;
        break;
      case 2:
        if (cValue < C40_SHIFT2_SET_CHARS.length) {
          unichar c40char = C40_SHIFT2_SET_CHARS[cValue];
          if (upperShift) {
            [result append:(unichar)(c40char + 128)];
            upperShift = NO;
          }
           else {
            [result append:c40char];
          }
        }
         else if (cValue == 27) {
          @throw [FormatException formatInstance];
        }
         else if (cValue == 30) {
          upperShift = YES;
        }
         else {
          @throw [FormatException formatInstance];
        }
        shift = 0;
        break;
      case 3:
        if (cValue < TEXT_SHIFT3_SET_CHARS.length) {
          unichar textChar = TEXT_SHIFT3_SET_CHARS[cValue];
          if (upperShift) {
            [result append:(unichar)(textChar + 128)];
            upperShift = NO;
          }
           else {
            [result append:textChar];
          }
          shift = 0;
        }
         else {
          @throw [FormatException formatInstance];
        }
        break;
      default:
        @throw [FormatException formatInstance];
      }
    }

  }
   while ([bits available] > 0);
}


/**
 * See ISO 16022:2006, 5.2.7
 */
+ (void) decodeAnsiX12Segment:(BitSource *)bits result:(StringBuffer *)result {
  NSArray * cValues = [NSArray array];

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
        [result append:'\r'];
      }
       else if (cValue == 1) {
        [result append:'*'];
      }
       else if (cValue == 2) {
        [result append:'>'];
      }
       else if (cValue == 3) {
        [result append:' '];
      }
       else if (cValue < 14) {
        [result append:(unichar)(cValue + 44)];
      }
       else if (cValue < 40) {
        [result append:(unichar)(cValue + 51)];
      }
       else {
        @throw [FormatException formatInstance];
      }
    }

  }
   while ([bits available] > 0);
}

+ (void) parseTwoBytes:(int)firstByte secondByte:(int)secondByte result:(NSArray *)result {
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
+ (void) decodeEdifactSegment:(BitSource *)bits result:(StringBuffer *)result {
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
        [result append:edifactValue];
      }
    }

  }
   while (!unlatch && [bits available] > 0);
}


/**
 * See ISO 16022:2006, 5.2.9 and Annex B, B.2
 */
+ (void) decodeBase256Segment:(BitSource *)bits result:(StringBuffer *)result byteSegments:(NSMutableArray *)byteSegments {
  int codewordPosition = 2;
  int d1 = [self unrandomize255State:[bits readBits:8] base256CodewordPosition:codewordPosition++];
  int count;
  if (d1 == 0) {
    count = [bits available] / 8;
  }
   else if (d1 < 250) {
    count = d1;
  }
   else {
    count = 250 * (d1 - 249) + [self unrandomize255State:[bits readBits:8] base256CodewordPosition:codewordPosition++];
  }
  if (count < 0) {
    @throw [FormatException formatInstance];
  }
  NSArray * bytes = [NSArray array];

  for (int i = 0; i < count; i++) {
    if ([bits available] < 8) {
      @throw [FormatException formatInstance];
    }
    bytes[i] = [self unrandomize255State:[bits readBits:8] base256CodewordPosition:codewordPosition++];
  }

  [byteSegments addObject:bytes];

  @try {
    [result append:[[[NSString alloc] init:bytes param1:@"ISO8859_1"] autorelease]];
  }
  @catch (UnsupportedEncodingException * uee) {
    @throw [[[NSException alloc] init:[@"Platform does not support required encoding: " stringByAppendingString:uee]] autorelease];
  }
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

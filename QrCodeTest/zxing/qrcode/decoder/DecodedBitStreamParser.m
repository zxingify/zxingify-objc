#import "DecodedBitStreamParser.h"


/**
 * See ISO 18004:2006, 6.4.4 Table 5
 */
NSArray * const ALPHANUMERIC_CHARS = [NSArray arrayWithObjects:'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', ' ', '$', '%', '*', '+', '-', '.', '/', ':', nil];
int const GB2312_SUBSET = 1;

@implementation DecodedBitStreamParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (DecoderResult *) decode:(NSArray *)bytes version:(Version *)version ecLevel:(ErrorCorrectionLevel *)ecLevel hints:(NSMutableDictionary *)hints {
  BitSource * bits = [[[BitSource alloc] init:bytes] autorelease];
  StringBuffer * result = [[[StringBuffer alloc] init:50] autorelease];
  CharacterSetECI * currentCharacterSetECI = nil;
  BOOL fc1InEffect = NO;
  NSMutableArray * byteSegments = [[[NSMutableArray alloc] init:1] autorelease];
  Mode * mode;

  do {
    if ([bits available] < 4) {
      mode = Mode.TERMINATOR;
    }
     else {

      @try {
        mode = [Mode forBits:[bits readBits:4]];
      }
      @catch (IllegalArgumentException * iae) {
        @throw [FormatException formatInstance];
      }
    }
    if (![mode isEqualTo:Mode.TERMINATOR]) {
      if ([mode isEqualTo:Mode.FNC1_FIRST_POSITION] || [mode isEqualTo:Mode.FNC1_SECOND_POSITION]) {
        fc1InEffect = YES;
      }
       else if ([mode isEqualTo:Mode.STRUCTURED_APPEND]) {
        [bits readBits:16];
      }
       else if ([mode isEqualTo:Mode.ECI]) {
        int value = [self parseECIValue:bits];
        currentCharacterSetECI = [CharacterSetECI getCharacterSetECIByValue:value];
        if (currentCharacterSetECI == nil) {
          @throw [FormatException formatInstance];
        }
      }
       else {
        if ([mode isEqualTo:Mode.HANZI]) {
          int subset = [bits readBits:4];
          int countHanzi = [bits readBits:[mode getCharacterCountBits:version]];
          if (subset == GB2312_SUBSET) {
            [self decodeHanziSegment:bits result:result count:countHanzi];
          }
        }
         else {
          int count = [bits readBits:[mode getCharacterCountBits:version]];
          if ([mode isEqualTo:Mode.NUMERIC]) {
            [self decodeNumericSegment:bits result:result count:count];
          }
           else if ([mode isEqualTo:Mode.ALPHANUMERIC]) {
            [self decodeAlphanumericSegment:bits result:result count:count fc1InEffect:fc1InEffect];
          }
           else if ([mode isEqualTo:Mode.BYTE]) {
            [self decodeByteSegment:bits result:result count:count currentCharacterSetECI:currentCharacterSetECI byteSegments:byteSegments hints:hints];
          }
           else if ([mode isEqualTo:Mode.KANJI]) {
            [self decodeKanjiSegment:bits result:result count:count];
          }
           else {
            @throw [FormatException formatInstance];
          }
        }
      }
    }
  }
   while (![mode isEqualTo:Mode.TERMINATOR]);
  return [[[DecoderResult alloc] init:bytes param1:[result description] param2:[byteSegments empty] ? nil : byteSegments param3:ecLevel == nil ? nil : [ecLevel description]] autorelease];
}


/**
 * See specification GBT 18284-2000
 */
+ (void) decodeHanziSegment:(BitSource *)bits result:(StringBuffer *)result count:(int)count {
  if (count * 13 > [bits available]) {
    @throw [FormatException formatInstance];
  }
  NSArray * buffer = [NSArray array];
  int offset = 0;

  while (count > 0) {
    int twoBytes = [bits readBits:13];
    int assembledTwoBytes = ((twoBytes / 0x060) << 8) | (twoBytes % 0x060);
    if (assembledTwoBytes < 0x003BF) {
      assembledTwoBytes += 0x0A1A1;
    }
     else {
      assembledTwoBytes += 0x0A6A1;
    }
    buffer[offset] = (char)((assembledTwoBytes >> 8) & 0xFF);
    buffer[offset + 1] = (char)(assembledTwoBytes & 0xFF);
    offset += 2;
    count--;
  }


  @try {
    [result append:[[[NSString alloc] init:buffer param1:StringUtils.GB2312] autorelease]];
  }
  @catch (UnsupportedEncodingException * uee) {
    @throw [FormatException formatInstance];
  }
}

+ (void) decodeKanjiSegment:(BitSource *)bits result:(StringBuffer *)result count:(int)count {
  if (count * 13 > [bits available]) {
    @throw [FormatException formatInstance];
  }
  NSArray * buffer = [NSArray array];
  int offset = 0;

  while (count > 0) {
    int twoBytes = [bits readBits:13];
    int assembledTwoBytes = ((twoBytes / 0x0C0) << 8) | (twoBytes % 0x0C0);
    if (assembledTwoBytes < 0x01F00) {
      assembledTwoBytes += 0x08140;
    }
     else {
      assembledTwoBytes += 0x0C140;
    }
    buffer[offset] = (char)(assembledTwoBytes >> 8);
    buffer[offset + 1] = (char)assembledTwoBytes;
    offset += 2;
    count--;
  }


  @try {
    [result append:[[[NSString alloc] init:buffer param1:StringUtils.SHIFT_JIS] autorelease]];
  }
  @catch (UnsupportedEncodingException * uee) {
    @throw [FormatException formatInstance];
  }
}

+ (void) decodeByteSegment:(BitSource *)bits result:(StringBuffer *)result count:(int)count currentCharacterSetECI:(CharacterSetECI *)currentCharacterSetECI byteSegments:(NSMutableArray *)byteSegments hints:(NSMutableDictionary *)hints {
  if (count << 3 > [bits available]) {
    @throw [FormatException formatInstance];
  }
  NSArray * readBytes = [NSArray array];

  for (int i = 0; i < count; i++) {
    readBytes[i] = (char)[bits readBits:8];
  }

  NSString * encoding;
  if (currentCharacterSetECI == nil) {
    encoding = [StringUtils guessEncoding:readBytes param1:hints];
  }
   else {
    encoding = [currentCharacterSetECI encodingName];
  }

  @try {
    [result append:[[[NSString alloc] init:readBytes param1:encoding] autorelease]];
  }
  @catch (UnsupportedEncodingException * uce) {
    @throw [FormatException formatInstance];
  }
  [byteSegments addObject:readBytes];
}

+ (unichar) toAlphaNumericChar:(int)value {
  if (value >= ALPHANUMERIC_CHARS.length) {
    @throw [FormatException formatInstance];
  }
  return ALPHANUMERIC_CHARS[value];
}

+ (void) decodeAlphanumericSegment:(BitSource *)bits result:(StringBuffer *)result count:(int)count fc1InEffect:(BOOL)fc1InEffect {
  int start = [result length];

  while (count > 1) {
    int nextTwoCharsBits = [bits readBits:11];
    [result append:[self toAlphaNumericChar:nextTwoCharsBits / 45]];
    [result append:[self toAlphaNumericChar:nextTwoCharsBits % 45]];
    count -= 2;
  }

  if (count == 1) {
    [result append:[self toAlphaNumericChar:[bits readBits:6]]];
  }
  if (fc1InEffect) {

    for (int i = start; i < [result length]; i++) {
      if ([result charAt:i] == '%') {
        if (i < [result length] - 1 && [result charAt:i + 1] == '%') {
          [result deleteCharAt:i + 1];
        }
         else {
          [result setCharAt:i param1:(unichar)0x1D];
        }
      }
    }

  }
}

+ (void) decodeNumericSegment:(BitSource *)bits result:(StringBuffer *)result count:(int)count {

  while (count >= 3) {
    int threeDigitsBits = [bits readBits:10];
    if (threeDigitsBits >= 1000) {
      @throw [FormatException formatInstance];
    }
    [result append:[self toAlphaNumericChar:threeDigitsBits / 100]];
    [result append:[self toAlphaNumericChar:(threeDigitsBits / 10) % 10]];
    [result append:[self toAlphaNumericChar:threeDigitsBits % 10]];
    count -= 3;
  }

  if (count == 2) {
    int twoDigitsBits = [bits readBits:7];
    if (twoDigitsBits >= 100) {
      @throw [FormatException formatInstance];
    }
    [result append:[self toAlphaNumericChar:twoDigitsBits / 10]];
    [result append:[self toAlphaNumericChar:twoDigitsBits % 10]];
  }
   else if (count == 1) {
    int digitBits = [bits readBits:4];
    if (digitBits >= 10) {
      @throw [FormatException formatInstance];
    }
    [result append:[self toAlphaNumericChar:digitBits]];
  }
}

+ (int) parseECIValue:(BitSource *)bits {
  int firstByte = [bits readBits:8];
  if ((firstByte & 0x80) == 0) {
    return firstByte & 0x7F;
  }
   else if ((firstByte & 0xC0) == 0x80) {
    int secondByte = [bits readBits:8];
    return ((firstByte & 0x3F) << 8) | secondByte;
  }
   else if ((firstByte & 0xE0) == 0xC0) {
    int secondThirdBytes = [bits readBits:16];
    return ((firstByte & 0x1F) << 16) | secondThirdBytes;
  }
  @throw [[[IllegalArgumentException alloc] init:[@"Bad ECI bits starting with byte " stringByAppendingString:firstByte]] autorelease];
}

@end

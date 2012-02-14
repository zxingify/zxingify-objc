#import "BitSource.h"
#import "CharacterSetECI.h"
#import "DecoderResult.h"
#import "ErrorCorrectionLevel.h"
#import "FormatException.h"
#import "Mode.h"
#import "QRCodeDecodedBitStreamParser.h"
#import "QRCodeVersion.h"
#import "StringUtils.h"


/**
 * See ISO 18004:2006, 6.4.4 Table 5
 */
char const ALPHANUMERIC_CHARS[45] = {
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B',
  'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
  'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ' ', '$', '%', '*', '+', '-', '.', '/', ':'
};

int const GB2312_SUBSET = 1;

@interface QRCodeDecodedBitStreamParser ()

+ (void) decodeHanziSegment:(BitSource *)bits result:(NSMutableString *)result count:(int)count;
+ (void) decodeKanjiSegment:(BitSource *)bits result:(NSMutableString *)result count:(int)count;
+ (void) decodeByteSegment:(BitSource *)bits result:(NSMutableString *)result count:(int)count currentCharacterSetECI:(CharacterSetECI *)currentCharacterSetECI byteSegments:(NSMutableArray *)byteSegments hints:(NSMutableDictionary *)hints;
+ (void) decodeAlphanumericSegment:(BitSource *)bits result:(NSMutableString *)result count:(int)count fc1InEffect:(BOOL)fc1InEffect;
+ (void) decodeNumericSegment:(BitSource *)bits result:(NSMutableString *)result count:(int)count;
+ (int) parseECIValue:(BitSource *)bits;

@end

@implementation QRCodeDecodedBitStreamParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (DecoderResult *) decode:(char *)bytes version:(QRCodeVersion *)version ecLevel:(ErrorCorrectionLevel *)ecLevel hints:(NSMutableDictionary *)hints {
  BitSource * bits = [[[BitSource alloc] initWithBytes:bytes] autorelease];
  NSMutableString * result = [NSMutableString stringWithCapacity:50];
  CharacterSetECI * currentCharacterSetECI = nil;
  BOOL fc1InEffect = NO;
  NSMutableArray * byteSegments = [NSMutableArray arrayWithCapacity:1];
  Mode * mode;

  do {
    if ([bits available] < 4) {
      mode = [Mode terminatorMode];
    } else {
      @try {
        mode = [Mode forBits:[bits readBits:4]];
      }
      @catch (NSException * iae) {
        @throw [FormatException formatInstance];
      }
    }
    if (![mode isEqual:[Mode terminatorMode]]) {
      if ([mode isEqual:[Mode fnc1FirstPositionMode]] || [mode isEqual:[Mode fnc1SecondPositionMode]]) {
        fc1InEffect = YES;
      } else if ([mode isEqual:[Mode structuredAppendMode]]) {
        [bits readBits:16];
      } else if ([mode isEqual:[Mode eciMode]]) {
        int value = [self parseECIValue:bits];
        currentCharacterSetECI = [CharacterSetECI getCharacterSetECIByValue:value];
        if (currentCharacterSetECI == nil) {
          @throw [FormatException formatInstance];
        }
      } else {
        if ([mode isEqual:[Mode hanziMode]]) {
          int subset = [bits readBits:4];
          int countHanzi = [bits readBits:[mode getCharacterCountBits:version]];
          if (subset == GB2312_SUBSET) {
            [self decodeHanziSegment:bits result:result count:countHanzi];
          }
        } else {
          int count = [bits readBits:[mode getCharacterCountBits:version]];
          if ([mode isEqual:[Mode numericMode]]) {
            [self decodeNumericSegment:bits result:result count:count];
          } else if ([mode isEqual:[Mode alphanumericMode]]) {
            [self decodeAlphanumericSegment:bits result:result count:count fc1InEffect:fc1InEffect];
          } else if ([mode isEqual:[Mode byteMode]]) {
            [self decodeByteSegment:bits result:result count:count currentCharacterSetECI:currentCharacterSetECI byteSegments:byteSegments hints:hints];
          } else if ([mode isEqual:[Mode kanjiMode]]) {
            [self decodeKanjiSegment:bits result:result count:count];
          } else {
            @throw [FormatException formatInstance];
          }
        }
      }
    }
  }
   while (![mode isEqual:[Mode terminatorMode]]);
  return [[[DecoderResult alloc] init:bytes text:[result description] byteSegments:[byteSegments count] == 0 ? nil : byteSegments ecLevel:ecLevel == nil ? nil : [ecLevel description]] autorelease];
}


/**
 * See specification GBT 18284-2000
 */
+ (void) decodeHanziSegment:(BitSource *)bits result:(NSMutableString *)result count:(int)count {
  if (count * 13 > [bits available]) {
    @throw [FormatException formatInstance];
  }

  NSMutableData *buffer = [NSMutableData dataWithCapacity:2 * count];
  while (count > 0) {
    int twoBytes = [bits readBits:13];
    int assembledTwoBytes = ((twoBytes / 0x060) << 8) | (twoBytes % 0x060);
    if (assembledTwoBytes < 0x003BF) {
      assembledTwoBytes += 0x0A1A1;
    }
     else {
      assembledTwoBytes += 0x0A6A1;
    }
    char bytes[2];
    bytes[0] = (char)((assembledTwoBytes >> 8) & 0xFF);
    bytes[1] = (char)(assembledTwoBytes & 0xFF);

    [buffer appendBytes:bytes length:2];

    count--;
  }

  [result appendString:[[[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding] autorelease]];
}

+ (void) decodeKanjiSegment:(BitSource *)bits result:(NSMutableString *)result count:(int)count {
  if (count * 13 > [bits available]) {
    @throw [FormatException formatInstance];
  }

  NSMutableData *buffer = [NSMutableData dataWithCapacity:2 * count];
  while (count > 0) {
    int twoBytes = [bits readBits:13];
    int assembledTwoBytes = ((twoBytes / 0x0C0) << 8) | (twoBytes % 0x0C0);
    if (assembledTwoBytes < 0x01F00) {
      assembledTwoBytes += 0x08140;
    }
     else {
      assembledTwoBytes += 0x0C140;
    }
    char bytes[2];
    bytes[0] = (char)(assembledTwoBytes >> 8);
    bytes[1] = (char)assembledTwoBytes;
    
    [buffer appendBytes:bytes length:2];

    count--;
  }

  [result appendString:[[[NSString alloc] initWithData:buffer encoding:NSShiftJISStringEncoding] autorelease]];
}

+ (void) decodeByteSegment:(BitSource *)bits result:(NSMutableString *)result count:(int)count currentCharacterSetECI:(CharacterSetECI *)currentCharacterSetECI byteSegments:(NSMutableArray *)byteSegments hints:(NSMutableDictionary *)hints {
  if (count << 3 > [bits available]) {
    @throw [FormatException formatInstance];
  }
  char readBytes[count];
  NSMutableArray *readBytesArray = [NSMutableArray arrayWithCapacity:count];

  for (int i = 0; i < count; i++) {
    readBytes[i] = (char)[bits readBits:8];
    [readBytesArray addObject:[NSNumber numberWithChar:readBytes[i]]];
  }

  NSStringEncoding encoding;
  if (currentCharacterSetECI == nil) {
    encoding = [StringUtils guessEncoding:readBytes length:count hints:hints];
  } else {
    encoding = [currentCharacterSetECI encoding];
  }

  [result appendString:[[[NSString alloc] initWithCString:readBytes encoding:encoding] autorelease]];
  
  [byteSegments addObject:readBytesArray];
}

+ (unichar) toAlphaNumericChar:(int)value {
  if (value >= 45) {
    @throw [FormatException formatInstance];
  }
  return ALPHANUMERIC_CHARS[value];
}

+ (void) decodeAlphanumericSegment:(BitSource *)bits result:(NSMutableString *)result count:(int)count fc1InEffect:(BOOL)fc1InEffect {
  int start = [result length];

  while (count > 1) {
    int nextTwoCharsBits = [bits readBits:11];
    [result appendFormat:@"%c", [self toAlphaNumericChar:nextTwoCharsBits / 45]];
    [result appendFormat:@"%c", [self toAlphaNumericChar:nextTwoCharsBits % 45]];
    count -= 2;
  }

  if (count == 1) {
    [result appendFormat:@"%c", [self toAlphaNumericChar:[bits readBits:6]]];
  }
  if (fc1InEffect) {
    for (int i = start; i < [result length]; i++) {
      if ([result characterAtIndex:i] == '%') {
        if (i < [result length] - 1 && [result characterAtIndex:i + 1] == '%') {
          [result deleteCharactersInRange:NSMakeRange(i + 1, 1)];
        } else {
          [result insertString:[NSString stringWithFormat:@"%c", (unichar)0x1D]
                       atIndex:i];
        }
      }
    }

  }
}

+ (void) decodeNumericSegment:(BitSource *)bits result:(NSMutableString *)result count:(int)count {

  while (count >= 3) {
    int threeDigitsBits = [bits readBits:10];
    if (threeDigitsBits >= 1000) {
      @throw [FormatException formatInstance];
    }
    [result appendFormat:@"%c", [self toAlphaNumericChar:threeDigitsBits / 100]];
    [result appendFormat:@"%c", [self toAlphaNumericChar:(threeDigitsBits / 10) % 10]];
    [result appendFormat:@"%c", [self toAlphaNumericChar:threeDigitsBits % 10]];
    count -= 3;
  }

  if (count == 2) {
    int twoDigitsBits = [bits readBits:7];
    if (twoDigitsBits >= 100) {
      @throw [FormatException formatInstance];
    }
    [result appendFormat:@"%c", [self toAlphaNumericChar:twoDigitsBits / 10]];
    [result appendFormat:@"%c", [self toAlphaNumericChar:twoDigitsBits % 10]];
  }
   else if (count == 1) {
    int digitBits = [bits readBits:4];
    if (digitBits >= 10) {
      @throw [FormatException formatInstance];
    }
    [result appendFormat:@"%c", [self toAlphaNumericChar:digitBits]];
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
  @throw [NSException exceptionWithName:NSInvalidArgumentException
                                 reason:[NSString stringWithFormat:@"Bad ECI bits starting with byte: %c", firstByte]
                               userInfo:nil];
}

@end

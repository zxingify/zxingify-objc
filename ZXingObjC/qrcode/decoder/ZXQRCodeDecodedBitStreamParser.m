#import "ZXBitSource.h"
#import "ZXCharacterSetECI.h"
#import "ZXDecoderResult.h"
#import "ZXErrorCorrectionLevel.h"
#import "ZXFormatException.h"
#import "ZXMode.h"
#import "ZXQRCodeDecodedBitStreamParser.h"
#import "ZXQRCodeVersion.h"
#import "ZXStringUtils.h"


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

@interface ZXQRCodeDecodedBitStreamParser ()

+ (void) decodeHanziSegment:(ZXBitSource *)bits result:(NSMutableString *)result count:(int)count;
+ (void) decodeKanjiSegment:(ZXBitSource *)bits result:(NSMutableString *)result count:(int)count;
+ (void) decodeByteSegment:(ZXBitSource *)bits result:(NSMutableString *)result count:(int)count currentCharacterSetECI:(ZXCharacterSetECI *)currentCharacterSetECI byteSegments:(NSMutableArray *)byteSegments hints:(ZXDecodeHints *)hints;
+ (void) decodeAlphanumericSegment:(ZXBitSource *)bits result:(NSMutableString *)result count:(int)count fc1InEffect:(BOOL)fc1InEffect;
+ (void) decodeNumericSegment:(ZXBitSource *)bits result:(NSMutableString *)result count:(int)count;
+ (int) parseECIValue:(ZXBitSource *)bits;

@end

@implementation ZXQRCodeDecodedBitStreamParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (ZXDecoderResult *) decode:(unsigned char *)bytes length:(unsigned int)length version:(ZXQRCodeVersion *)version ecLevel:(ZXErrorCorrectionLevel *)ecLevel hints:(ZXDecodeHints *)hints {
  ZXBitSource * bits = [[[ZXBitSource alloc] initWithBytes:bytes length:length] autorelease];
  NSMutableString * result = [NSMutableString stringWithCapacity:50];
  ZXCharacterSetECI * currentCharacterSetECI = nil;
  BOOL fc1InEffect = NO;
  NSMutableArray * byteSegments = [NSMutableArray arrayWithCapacity:1];
  ZXMode * mode;

  do {
    if ([bits available] < 4) {
      mode = [ZXMode terminatorMode];
    } else {
      @try {
        mode = [ZXMode forBits:[bits readBits:4]];
      }
      @catch (NSException * iae) {
        @throw [ZXFormatException formatInstance];
      }
    }
    if (![mode isEqual:[ZXMode terminatorMode]]) {
      if ([mode isEqual:[ZXMode fnc1FirstPositionMode]] || [mode isEqual:[ZXMode fnc1SecondPositionMode]]) {
        fc1InEffect = YES;
      } else if ([mode isEqual:[ZXMode structuredAppendMode]]) {
        [bits readBits:16];
      } else if ([mode isEqual:[ZXMode eciMode]]) {
        int value = [self parseECIValue:bits];
        currentCharacterSetECI = [ZXCharacterSetECI characterSetECIByValue:value];
        if (currentCharacterSetECI == nil) {
          @throw [ZXFormatException formatInstance];
        }
      } else {
        if ([mode isEqual:[ZXMode hanziMode]]) {
          int subset = [bits readBits:4];
          int countHanzi = [bits readBits:[mode getCharacterCountBits:version]];
          if (subset == GB2312_SUBSET) {
            [self decodeHanziSegment:bits result:result count:countHanzi];
          }
        } else {
          int count = [bits readBits:[mode getCharacterCountBits:version]];
          if ([mode isEqual:[ZXMode numericMode]]) {
            [self decodeNumericSegment:bits result:result count:count];
          } else if ([mode isEqual:[ZXMode alphanumericMode]]) {
            [self decodeAlphanumericSegment:bits result:result count:count fc1InEffect:fc1InEffect];
          } else if ([mode isEqual:[ZXMode byteMode]]) {
            [self decodeByteSegment:bits result:result count:count currentCharacterSetECI:currentCharacterSetECI byteSegments:byteSegments hints:hints];
          } else if ([mode isEqual:[ZXMode kanjiMode]]) {
            [self decodeKanjiSegment:bits result:result count:count];
          } else {
            @throw [ZXFormatException formatInstance];
          }
        }
      }
    }
  } while (![mode isEqual:[ZXMode terminatorMode]]);
  return [[[ZXDecoderResult alloc] initWithRawBytes:bytes
                                             length:length
                                               text:[result description]
                                       byteSegments:[byteSegments count] == 0 ? nil : byteSegments
                                            ecLevel:ecLevel == nil ? nil : [ecLevel description]] autorelease];
}


/**
 * See specification GBT 18284-2000
 */
+ (void) decodeHanziSegment:(ZXBitSource *)bits result:(NSMutableString *)result count:(int)count {
  if (count * 13 > [bits available]) {
    @throw [ZXFormatException formatInstance];
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

  NSString *string = [[[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding] autorelease];
  if (string) {
    [result appendString:string];
  }
}

+ (void) decodeKanjiSegment:(ZXBitSource *)bits result:(NSMutableString *)result count:(int)count {
  if (count * 13 > [bits available]) {
    @throw [ZXFormatException formatInstance];
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

  NSString *string = [[[NSString alloc] initWithData:buffer encoding:NSShiftJISStringEncoding] autorelease];
  if (string) {
    [result appendString:string];
  }
}

+ (void) decodeByteSegment:(ZXBitSource *)bits result:(NSMutableString *)result count:(int)count currentCharacterSetECI:(ZXCharacterSetECI *)currentCharacterSetECI byteSegments:(NSMutableArray *)byteSegments hints:(ZXDecodeHints *)hints {
  if (count << 3 > [bits available]) {
    @throw [ZXFormatException formatInstance];
  }
  unsigned char readBytes[count];
  NSMutableArray *readBytesArray = [NSMutableArray arrayWithCapacity:count];

  for (int i = 0; i < count; i++) {
    readBytes[i] = (char)[bits readBits:8];
    [readBytesArray addObject:[NSNumber numberWithChar:readBytes[i]]];
  }

  NSStringEncoding encoding;
  if (currentCharacterSetECI == nil) {
    encoding = [ZXStringUtils guessEncoding:readBytes length:count hints:hints];
  } else {
    encoding = [currentCharacterSetECI encoding];
  }

  NSString *string = [[[NSString alloc] initWithBytes:readBytes length:count encoding:encoding] autorelease];
  if (string) {
    [result appendString:string];
  }
  
  [byteSegments addObject:readBytesArray];
}

+ (unichar) toAlphaNumericChar:(int)value {
  if (value >= 45) {
    @throw [ZXFormatException formatInstance];
  }
  return ALPHANUMERIC_CHARS[value];
}

+ (void) decodeAlphanumericSegment:(ZXBitSource *)bits result:(NSMutableString *)result count:(int)count fc1InEffect:(BOOL)fc1InEffect {
  int start = [result length];

  while (count > 1) {
    int nextTwoCharsBits = [bits readBits:11];
    [result appendFormat:@"%C", [self toAlphaNumericChar:nextTwoCharsBits / 45]];
    [result appendFormat:@"%C", [self toAlphaNumericChar:nextTwoCharsBits % 45]];
    count -= 2;
  }

  if (count == 1) {
    [result appendFormat:@"%C", [self toAlphaNumericChar:[bits readBits:6]]];
  }
  if (fc1InEffect) {
    for (int i = start; i < [result length]; i++) {
      if ([result characterAtIndex:i] == '%') {
        if (i < [result length] - 1 && [result characterAtIndex:i + 1] == '%') {
          [result deleteCharactersInRange:NSMakeRange(i + 1, 1)];
        } else {
          [result insertString:[NSString stringWithFormat:@"%C", (unichar)0x1D]
                       atIndex:i];
        }
      }
    }

  }
}

+ (void) decodeNumericSegment:(ZXBitSource *)bits result:(NSMutableString *)result count:(int)count {

  while (count >= 3) {
    int threeDigitsBits = [bits readBits:10];
    if (threeDigitsBits >= 1000) {
      @throw [ZXFormatException formatInstance];
    }
    [result appendFormat:@"%C", [self toAlphaNumericChar:threeDigitsBits / 100]];
    [result appendFormat:@"%C", [self toAlphaNumericChar:(threeDigitsBits / 10) % 10]];
    [result appendFormat:@"%C", [self toAlphaNumericChar:threeDigitsBits % 10]];
    count -= 3;
  }

  if (count == 2) {
    int twoDigitsBits = [bits readBits:7];
    if (twoDigitsBits >= 100) {
      @throw [ZXFormatException formatInstance];
    }
    [result appendFormat:@"%C", [self toAlphaNumericChar:twoDigitsBits / 10]];
    [result appendFormat:@"%C", [self toAlphaNumericChar:twoDigitsBits % 10]];
  }
   else if (count == 1) {
    int digitBits = [bits readBits:4];
    if (digitBits >= 10) {
      @throw [ZXFormatException formatInstance];
    }
    [result appendFormat:@"%C", [self toAlphaNumericChar:digitBits]];
  }
}

+ (int) parseECIValue:(ZXBitSource *)bits {
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
                                 reason:[NSString stringWithFormat:@"Bad ECI bits starting with byte: %d", firstByte]
                               userInfo:nil];
}

@end

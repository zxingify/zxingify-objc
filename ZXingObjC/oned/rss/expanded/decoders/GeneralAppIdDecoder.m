#import "BitArray.h"
#import "BlockParsedResult.h"
#import "CurrentParsingState.h"
#import "DecodedChar.h"
#import "DecodedInformation.h"
#import "DecodedNumeric.h"
#import "FieldParser.h"
#import "GeneralAppIdDecoder.h"

@interface GeneralAppIdDecoder ()

- (DecodedChar *) decodeAlphanumeric:(int)pos;
- (DecodedChar *) decodeIsoIec646:(int)pos;
- (DecodedNumeric *) decodeNumeric:(int)pos;
- (BOOL) isAlphaOr646ToNumericLatch:(int)pos;
- (BOOL) isAlphaTo646ToAlphaLatch:(int)pos;
- (BOOL) isNumericToAlphaNumericLatch:(int)pos;
- (BOOL) isStillAlpha:(int)pos;
- (BOOL) isStillIsoIec646:(int)pos;
- (BOOL) isStillNumeric:(int)pos;
- (BlockParsedResult *) parseAlphaBlock;
- (DecodedInformation *) parseBlocks;
- (BlockParsedResult *) parseIsoIec646Block;
- (BlockParsedResult *) parseNumericBlock;

@end

@implementation GeneralAppIdDecoder

- (id) initWithInformation:(BitArray *)anInformation {
  if (self = [super init]) {
    current = [[CurrentParsingState alloc] init];
    buffer = [[NSMutableString alloc] init];
    information = [anInformation retain];
  }
  return self;
}

- (NSString *) decodeAllCodes:(NSMutableString *)buff initialPosition:(int)initialPosition {
  int currentPosition = initialPosition;
  NSString * remaining = nil;
  do {
    DecodedInformation * info = [self decodeGeneralPurposeField:currentPosition remaining:remaining];
    NSString * parsedFields = [FieldParser parseFieldsInGeneralPurpose:[info theNewString]];
    [buff appendString:parsedFields];
    if ([info remaining]) {
      remaining = [[NSNumber numberWithInt:[info remainingValue]] stringValue];
    } else {
      remaining = nil;
    }

    if (currentPosition == [info theNewPosition]) {
      break;
    }
    currentPosition = [info theNewPosition];
  } while (YES);

  return [NSString stringWithString:buff];
}

- (BOOL) isStillNumeric:(int)pos {
  if (pos + 7 > information.size) {
    return pos + 4 <= information.size;
  }

  for (int i = pos; i < pos + 3; ++i) {
    if ([information get:i]) {
      return YES;
    }
  }

  return [information get:pos + 3];
}

- (DecodedNumeric *) decodeNumeric:(int)pos {
  if (pos + 7 > information.size) {
    int numeric = [self extractNumericValueFromBitArray:pos bits:4];
    if (numeric == 0) {
      return [[[DecodedNumeric alloc] initWithNewPosition:information.size
                                               firstDigit:FNC1
                                              secondDigit:FNC1] autorelease];
    }
    return [[[DecodedNumeric alloc] initWithNewPosition:information.size
                                             firstDigit:numeric - 1
                                            secondDigit:FNC1] autorelease];
  }
  int numeric = [self extractNumericValueFromBitArray:pos bits:7];

  int digit1 = (numeric - 8) / 11;
  int digit2 = (numeric - 8) % 11;

  return [[[DecodedNumeric alloc] initWithNewPosition:pos + 7
                                               firstDigit:digit1
                                               secondDigit:digit2] autorelease];
}

- (int) extractNumericValueFromBitArray:(int)pos bits:(int)bits {
  return [GeneralAppIdDecoder extractNumericValueFromBitArray:information pos:pos bits:bits];
}

+ (int) extractNumericValueFromBitArray:(BitArray *)information pos:(int)pos bits:(int)bits {
  if (bits > 32) {
    [NSException raise:NSInvalidArgumentException format:@"extractNumberValueFromBitArray can't handle more than 32 bits"];
  }

  int value = 0;
  for (int i = 0; i < bits; ++i) {
    if ([information get:pos + i]) {
      value |= (1 << (bits - i - 1));
    }
  }

  return value;
}

- (DecodedInformation *) decodeGeneralPurposeField:(int)pos remaining:(NSString *)remaining {
  [buffer setString:@""];

  if (remaining != nil) {
    [buffer appendString:remaining];
  }

  current.position = pos;

  DecodedInformation * lastDecoded = [self parseBlocks];
  if (lastDecoded != nil && [lastDecoded remaining]) {
    return [[[DecodedInformation alloc] initWithNewPosition:current.position
                                                  newString:buffer
                                             remainingValue:[lastDecoded remainingValue]] autorelease];
  }
  return [[[DecodedInformation alloc] initWithNewPosition:current.position newString:buffer] autorelease];
}

- (DecodedInformation *) parseBlocks {
  BOOL isFinished;
  BlockParsedResult * result;
  do {
    int initialPosition = current.position;

    if ([current alpha]) {
      result = [self parseAlphaBlock];
      isFinished = [result finished];
    } else if ([current isoIec646]) {
      result = [self parseIsoIec646Block];
      isFinished = [result finished];
    } else {
      result = [self parseNumericBlock];
      isFinished = [result finished];
    }

    BOOL positionChanged = initialPosition != current.position;
    if (!positionChanged && !isFinished) {
      break;
    }
  }
   while (!isFinished);
  return [result decodedInformation];
}

- (BlockParsedResult *) parseNumericBlock {
  while ([self isStillNumeric:current.position]) {
    DecodedNumeric * numeric = [self decodeNumeric:current.position];
    current.position = numeric.theNewPosition;

    if ([numeric firstDigitFNC1]) {
      DecodedInformation * _information;
      if ([numeric secondDigitFNC1]) {
        _information = [[[DecodedInformation alloc] initWithNewPosition:current.position
                                                              newString:buffer] autorelease];
      } else {
        _information = [[[DecodedInformation alloc] initWithNewPosition:current.position
                                                              newString:buffer
                                                         remainingValue:[numeric secondDigit]] autorelease];
      }
      return [[[BlockParsedResult alloc] initWithInformation:_information finished:YES] autorelease];
    }
    [buffer appendFormat:@"%d", [numeric firstDigit]];

    if ([numeric secondDigitFNC1]) {
      DecodedInformation * _information = [[[DecodedInformation alloc] initWithNewPosition:current.position
                                                                                newString:buffer] autorelease];
      return [[[BlockParsedResult alloc] initWithInformation:_information finished:YES] autorelease];
    }
    [buffer appendFormat:@"%d", [numeric secondDigit]];
  }

  if ([self isNumericToAlphaNumericLatch:current.position]) {
    [current setAlpha];
    current.position += 4;
  }
  return [[[BlockParsedResult alloc] initWithFinished:NO] autorelease];
}

- (BlockParsedResult *) parseIsoIec646Block {
  while ([self isStillIsoIec646:current.position]) {
    DecodedChar * iso = [self decodeIsoIec646:current.position];
    current.position = iso.theNewPosition;

    if ([iso fnc1]) {
      DecodedInformation * _information = [[[DecodedInformation alloc] initWithNewPosition:current.position
                                                                                   newString:buffer] autorelease];
      return [[[BlockParsedResult alloc] initWithInformation:_information finished:YES] autorelease];
    }
    [buffer appendFormat:@"%C", [iso value]];
  }

  if ([self isAlphaOr646ToNumericLatch:current.position]) {
    current.position += 3;
    [current setNumeric];
  } else if ([self isAlphaTo646ToAlphaLatch:current.position]) {
    if (current.position + 5 < information.size) {
      current.position += 5;
    } else {
      current.position = information.size;
    }

    [current setAlpha];
  }
  return [[[BlockParsedResult alloc] initWithFinished:NO] autorelease];
}

- (BlockParsedResult *) parseAlphaBlock {
  while ([self isStillAlpha:current.position]) {
    DecodedChar * alpha = [self decodeAlphanumeric:current.position];
    current.position = alpha.theNewPosition;

    if ([alpha fnc1]) {
      DecodedInformation * _information = [[[DecodedInformation alloc] initWithNewPosition:current.position
                                                                                   newString:buffer] autorelease];
      return [[[BlockParsedResult alloc] initWithInformation:_information finished:YES] autorelease];
    }

    [buffer appendFormat:@"%C", [alpha value]];
  }

  if ([self isAlphaOr646ToNumericLatch:current.position]) {
    current.position += 3;
    [current setNumeric];
  } else if ([self isAlphaTo646ToAlphaLatch:current.position]) {
    if (current.position + 5 < information.size) {
      current.position += 5;
    } else {
      current.position = information.size;
    }

    [current setIsoIec646];
  }
  return [[[BlockParsedResult alloc] initWithFinished:NO] autorelease];
}

- (BOOL) isStillIsoIec646:(int)pos {
  if (pos + 5 > information.size) {
    return NO;
  }

  int fiveBitValue = [self extractNumericValueFromBitArray:pos bits:5];
  if (fiveBitValue >= 5 && fiveBitValue < 16) {
    return YES;
  }

  if (pos + 7 > information.size) {
    return NO;
  }

  int sevenBitValue = [self extractNumericValueFromBitArray:pos bits:7];
  if (sevenBitValue >= 64 && sevenBitValue < 116) {
    return YES;
  }

  if (pos + 8 > information.size) {
    return NO;
  }

  int eightBitValue = [self extractNumericValueFromBitArray:pos bits:8];
  return eightBitValue >= 232 && eightBitValue < 253;
}

- (DecodedChar *) decodeIsoIec646:(int)pos {
  int fiveBitValue = [self extractNumericValueFromBitArray:pos bits:5];
  if (fiveBitValue == 15) {
    return [[[DecodedChar alloc] initWithNewPosition:pos + 5 value:FNC1] autorelease];
  }

  if (fiveBitValue >= 5 && fiveBitValue < 15) {
    return [[[DecodedChar alloc] initWithNewPosition:pos + 5 value:(unichar)('0' + fiveBitValue - 5)] autorelease];
  }

  int sevenBitValue = [self extractNumericValueFromBitArray:pos bits:7];

  if (sevenBitValue >= 64 && sevenBitValue < 90) {
    return [[[DecodedChar alloc] initWithNewPosition:pos + 7 value:(unichar)(sevenBitValue + 1)] autorelease];
  }

  if (sevenBitValue >= 90 && sevenBitValue < 116) {
    return [[[DecodedChar alloc] initWithNewPosition:pos + 7 value:(unichar)(sevenBitValue + 7)] autorelease];
  }

  int eightBitValue = [self extractNumericValueFromBitArray:pos bits:8];
  switch (eightBitValue) {
  case 232:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'!'] autorelease];
  case 233:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'"'] autorelease];
  case 234:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'%'] autorelease];
  case 235:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'&'] autorelease];
  case 236:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'\''] autorelease];
  case 237:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'('] autorelease];
  case 238:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:')'] autorelease];
  case 239:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'*'] autorelease];
  case 240:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'+'] autorelease];
  case 241:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:','] autorelease];
  case 242:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'-'] autorelease];
  case 243:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'.'] autorelease];
  case 244:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'/'] autorelease];
  case 245:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:':'] autorelease];
  case 246:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:';'] autorelease];
  case 247:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'<'] autorelease];
  case 248:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'='] autorelease];
  case 249:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'>'] autorelease];
  case 250:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'?'] autorelease];
  case 251:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:'_'] autorelease];
  case 252:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 8 value:' '] autorelease];
  }

  [NSException raise:@"RuntimeException" format:@"Decoding invalid ISO/IEC 646 value: %d", eightBitValue];
}

- (BOOL) isStillAlpha:(int)pos {
  if (pos + 5 > information.size) {
    return NO;
  }

  int fiveBitValue = [self extractNumericValueFromBitArray:pos bits:5];
  if (fiveBitValue >= 5 && fiveBitValue < 16) {
    return YES;
  }

  if (pos + 6 > information.size) {
    return NO;
  }

  int sixBitValue = [self extractNumericValueFromBitArray:pos bits:6];
  return sixBitValue >= 16 && sixBitValue < 63;
}

- (DecodedChar *) decodeAlphanumeric:(int)pos {
  int fiveBitValue = [self extractNumericValueFromBitArray:pos bits:5];
  if (fiveBitValue == 15) {
    return [[[DecodedChar alloc] initWithNewPosition:pos + 5 value:FNC1] autorelease];
  }

  if (fiveBitValue >= 5 && fiveBitValue < 15) {
    return [[[DecodedChar alloc] initWithNewPosition:pos + 5 value:(unichar)('0' + fiveBitValue - 5)] autorelease];
  }

  int sixBitValue = [self extractNumericValueFromBitArray:pos bits:6];

  if (sixBitValue >= 32 && sixBitValue < 58) {
    return [[[DecodedChar alloc] initWithNewPosition:pos + 6 value:(unichar)(sixBitValue + 33)] autorelease];
  }

  switch (sixBitValue) {
  case 58:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 6 value:'*'] autorelease];
  case 59:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 6 value:','] autorelease];
  case 60:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 6 value:'-'] autorelease];
  case 61:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 6 value:'.'] autorelease];
  case 62:
    return [[[DecodedChar alloc] initWithNewPosition:pos + 6 value:'/'] autorelease];
  }

  [NSException raise:@"RuntimeException" format:@"Decoding invalid alphanumeric value: %d", sixBitValue];
}

- (BOOL) isAlphaTo646ToAlphaLatch:(int)pos {
  if (pos + 1 > information.size) {
    return NO;
  }

  for (int i = 0; i < 5 && i + pos < information.size; ++i) {
    if (i == 2) {
      if (![information get:pos + 2]) {
        return NO;
      }
    } else if ([information get:pos + i]) {
      return NO;
    }
  }

  return YES;
}

- (BOOL) isAlphaOr646ToNumericLatch:(int)pos {
  if (pos + 3 > information.size) {
    return NO;
  }

  for (int i = pos; i < pos + 3; ++i) {
    if ([information get:i]) {
      return NO;
    }
  }

  return YES;
}

- (BOOL) isNumericToAlphaNumericLatch:(int)pos {
  if (pos + 1 > information.size) {
    return NO;
  }

  for (int i = 0; i < 4 && i + pos < information.size; ++i) {
    if ([information get:pos + i]) {
      return NO;
    }
  }

  return YES;
}

- (void) dealloc {
  [information release];
  [current release];
  [buffer release];
  [super dealloc];
}

@end

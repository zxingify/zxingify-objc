#import "GeneralAppIdDecoder.h"

@implementation GeneralAppIdDecoder

- (id) initWithInformation:(BitArray *)information {
  if (self = [super init]) {
    current = [[[CurrentParsingState alloc] init] autorelease];
    buffer = [[[NSMutableString alloc] init] autorelease];
    information = information;
  }
  return self;
}

- (NSString *) decodeAllCodes:(NSMutableString *)buff initialPosition:(int)initialPosition {
  int currentPosition = initialPosition;
  NSString * remaining = nil;

  do {
    DecodedInformation * info = [self decodeGeneralPurposeField:currentPosition remaining:remaining];
    NSString * parsedFields = [FieldParser parseFieldsInGeneralPurpose:[info newString]];
    [buff append:parsedFields];
    if ([info remaining]) {
      remaining = [String valueOf:[info remainingValue]];
    }
     else {
      remaining = nil;
    }
    if (currentPosition == [info newPosition]) {
      break;
    }
    currentPosition = [info newPosition];
  }
   while (YES);
  return [buff description];
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
      return [[[DecodedNumeric alloc] init:information.size param1:DecodedNumeric.FNC1 param2:DecodedNumeric.FNC1] autorelease];
    }
    return [[[DecodedNumeric alloc] init:information.size param1:numeric - 1 param2:DecodedNumeric.FNC1] autorelease];
  }
  int numeric = [self extractNumericValueFromBitArray:pos bits:7];
  int digit1 = (numeric - 8) / 11;
  int digit2 = (numeric - 8) % 11;
  return [[[DecodedNumeric alloc] init:pos + 7 param1:digit1 param2:digit2] autorelease];
}

- (int) extractNumericValueFromBitArray:(int)pos bits:(int)bits {
  return [self extractNumericValueFromBitArray:information pos:pos bits:bits];
}

- (int) extractNumericValueFromBitArray:(BitArray *)information pos:(int)pos bits:(int)bits {
  if (bits > 32) {
    @throw [[[IllegalArgumentException alloc] init:@"extractNumberValueFromBitArray can't handle more than 32 bits"] autorelease];
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
  [buffer setLength:0];
  if (remaining != nil) {
    [buffer append:remaining];
  }
  current.position = pos;
  DecodedInformation * lastDecoded = [self parseBlocks];
  if (lastDecoded != nil && [lastDecoded remaining]) {
    return [[[DecodedInformation alloc] init:current.position param1:[buffer description] param2:[lastDecoded remainingValue]] autorelease];
  }
  return [[[DecodedInformation alloc] init:current.position param1:[buffer description]] autorelease];
}

- (DecodedInformation *) parseBlocks {
  BOOL isFinished;
  BlockParsedResult * result;

  do {
    int initialPosition = current.position;
    if ([current alpha]) {
      result = [self parseAlphaBlock];
      isFinished = [result finished];
    }
     else if ([current isoIec646]) {
      result = [self parseIsoIec646Block];
      isFinished = [result finished];
    }
     else {
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
    current.position = [numeric newPosition];
    if ([numeric firstDigitFNC1]) {
      DecodedInformation * information;
      if ([numeric secondDigitFNC1]) {
        information = [[[DecodedInformation alloc] init:current.position param1:[buffer description]] autorelease];
      }
       else {
        information = [[[DecodedInformation alloc] init:current.position param1:[buffer description] param2:[numeric secondDigit]] autorelease];
      }
      return [[[BlockParsedResult alloc] init:information param1:YES] autorelease];
    }
    [buffer append:[numeric firstDigit]];
    if ([numeric secondDigitFNC1]) {
      DecodedInformation * information = [[[DecodedInformation alloc] init:current.position param1:[buffer description]] autorelease];
      return [[[BlockParsedResult alloc] init:information param1:YES] autorelease];
    }
    [buffer append:[numeric secondDigit]];
  }

  if ([self isNumericToAlphaNumericLatch:current.position]) {
    [current setAlpha];
    current.position += 4;
  }
  return [[[BlockParsedResult alloc] init:NO] autorelease];
}

- (BlockParsedResult *) parseIsoIec646Block {

  while ([self isStillIsoIec646:current.position]) {
    DecodedChar * iso = [self decodeIsoIec646:current.position];
    current.position = [iso newPosition];
    if ([iso fNC1]) {
      DecodedInformation * information = [[[DecodedInformation alloc] init:current.position param1:[buffer description]] autorelease];
      return [[[BlockParsedResult alloc] init:information param1:YES] autorelease];
    }
    [buffer append:[iso value]];
  }

  if ([self isAlphaOr646ToNumericLatch:current.position]) {
    current.position += 3;
    [current setNumeric];
  }
   else if ([self isAlphaTo646ToAlphaLatch:current.position]) {
    if (current.position + 5 < information.size) {
      current.position += 5;
    }
     else {
      current.position = information.size;
    }
    [current setAlpha];
  }
  return [[[BlockParsedResult alloc] init:NO] autorelease];
}

- (BlockParsedResult *) parseAlphaBlock {

  while ([self isStillAlpha:current.position]) {
    DecodedChar * alpha = [self decodeAlphanumeric:current.position];
    current.position = [alpha newPosition];
    if ([alpha fNC1]) {
      DecodedInformation * information = [[[DecodedInformation alloc] init:current.position param1:[buffer description]] autorelease];
      return [[[BlockParsedResult alloc] init:information param1:YES] autorelease];
    }
    [buffer append:[alpha value]];
  }

  if ([self isAlphaOr646ToNumericLatch:current.position]) {
    current.position += 3;
    [current setNumeric];
  }
   else if ([self isAlphaTo646ToAlphaLatch:current.position]) {
    if (current.position + 5 < information.size) {
      current.position += 5;
    }
     else {
      current.position = information.size;
    }
    [current setIsoIec646];
  }
  return [[[BlockParsedResult alloc] init:NO] autorelease];
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
    return [[[DecodedChar alloc] init:pos + 5 param1:DecodedChar.FNC1] autorelease];
  }
  if (fiveBitValue >= 5 && fiveBitValue < 15) {
    return [[[DecodedChar alloc] init:pos + 5 param1:(unichar)('0' + fiveBitValue - 5)] autorelease];
  }
  int sevenBitValue = [self extractNumericValueFromBitArray:pos bits:7];
  if (sevenBitValue >= 64 && sevenBitValue < 90) {
    return [[[DecodedChar alloc] init:pos + 7 param1:(unichar)(sevenBitValue + 1)] autorelease];
  }
  if (sevenBitValue >= 90 && sevenBitValue < 116) {
    return [[[DecodedChar alloc] init:pos + 7 param1:(unichar)(sevenBitValue + 7)] autorelease];
  }
  int eightBitValue = [self extractNumericValueFromBitArray:pos bits:8];

  switch (eightBitValue) {
  case 232:
    return [[[DecodedChar alloc] init:pos + 8 param1:'!'] autorelease];
  case 233:
    return [[[DecodedChar alloc] init:pos + 8 param1:'"'] autorelease];
  case 234:
    return [[[DecodedChar alloc] init:pos + 8 param1:'%'] autorelease];
  case 235:
    return [[[DecodedChar alloc] init:pos + 8 param1:'&'] autorelease];
  case 236:
    return [[[DecodedChar alloc] init:pos + 8 param1:'\''] autorelease];
  case 237:
    return [[[DecodedChar alloc] init:pos + 8 param1:'('] autorelease];
  case 238:
    return [[[DecodedChar alloc] init:pos + 8 param1:')'] autorelease];
  case 239:
    return [[[DecodedChar alloc] init:pos + 8 param1:'*'] autorelease];
  case 240:
    return [[[DecodedChar alloc] init:pos + 8 param1:'+'] autorelease];
  case 241:
    return [[[DecodedChar alloc] init:pos + 8 param1:','] autorelease];
  case 242:
    return [[[DecodedChar alloc] init:pos + 8 param1:'-'] autorelease];
  case 243:
    return [[[DecodedChar alloc] init:pos + 8 param1:'.'] autorelease];
  case 244:
    return [[[DecodedChar alloc] init:pos + 8 param1:'/'] autorelease];
  case 245:
    return [[[DecodedChar alloc] init:pos + 8 param1:':'] autorelease];
  case 246:
    return [[[DecodedChar alloc] init:pos + 8 param1:';'] autorelease];
  case 247:
    return [[[DecodedChar alloc] init:pos + 8 param1:'<'] autorelease];
  case 248:
    return [[[DecodedChar alloc] init:pos + 8 param1:'='] autorelease];
  case 249:
    return [[[DecodedChar alloc] init:pos + 8 param1:'>'] autorelease];
  case 250:
    return [[[DecodedChar alloc] init:pos + 8 param1:'?'] autorelease];
  case 251:
    return [[[DecodedChar alloc] init:pos + 8 param1:'_'] autorelease];
  case 252:
    return [[[DecodedChar alloc] init:pos + 8 param1:' '] autorelease];
  }
  @throw [[[NSException alloc] init:[@"Decoding invalid ISO/IEC 646 value: " stringByAppendingString:eightBitValue]] autorelease];
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
    return [[[DecodedChar alloc] init:pos + 5 param1:DecodedChar.FNC1] autorelease];
  }
  if (fiveBitValue >= 5 && fiveBitValue < 15) {
    return [[[DecodedChar alloc] init:pos + 5 param1:(unichar)('0' + fiveBitValue - 5)] autorelease];
  }
  int sixBitValue = [self extractNumericValueFromBitArray:pos bits:6];
  if (sixBitValue >= 32 && sixBitValue < 58) {
    return [[[DecodedChar alloc] init:pos + 6 param1:(unichar)(sixBitValue + 33)] autorelease];
  }

  switch (sixBitValue) {
  case 58:
    return [[[DecodedChar alloc] init:pos + 6 param1:'*'] autorelease];
  case 59:
    return [[[DecodedChar alloc] init:pos + 6 param1:','] autorelease];
  case 60:
    return [[[DecodedChar alloc] init:pos + 6 param1:'-'] autorelease];
  case 61:
    return [[[DecodedChar alloc] init:pos + 6 param1:'.'] autorelease];
  case 62:
    return [[[DecodedChar alloc] init:pos + 6 param1:'/'] autorelease];
  }
  @throw [[[NSException alloc] init:[@"Decoding invalid alphanumeric value: " stringByAppendingString:sixBitValue]] autorelease];
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
    }
     else if ([information get:pos + i]) {
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

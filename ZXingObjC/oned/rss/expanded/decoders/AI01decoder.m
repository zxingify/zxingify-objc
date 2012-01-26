#import "AI01decoder.h"

int const gtinSize = 40;

@implementation AI01decoder

- (id) initWithInformation:(BitArray *)information {
  if (self = [super init:information]) {
  }
  return self;
}

- (void) encodeCompressedGtin:(StringBuffer *)buf currentPos:(int)currentPos {
  [buf append:@"(01)"];
  int initialPosition = [buf length];
  [buf append:'9'];
  [self encodeCompressedGtinWithoutAI:buf currentPos:currentPos initialBufferPosition:initialPosition];
}

- (void) encodeCompressedGtinWithoutAI:(StringBuffer *)buf currentPos:(int)currentPos initialBufferPosition:(int)initialBufferPosition {

  for (int i = 0; i < 4; ++i) {
    int currentBlock = [generalDecoder extractNumericValueFromBitArray:currentPos + 10 * i param1:10];
    if (currentBlock / 100 == 0) {
      [buf append:'0'];
    }
    if (currentBlock / 10 == 0) {
      [buf append:'0'];
    }
    [buf append:currentBlock];
  }

  [self appendCheckDigit:buf currentPos:initialBufferPosition];
}

+ (void) appendCheckDigit:(StringBuffer *)buf currentPos:(int)currentPos {
  int checkDigit = 0;

  for (int i = 0; i < 13; i++) {
    int digit = [buf charAt:i + currentPos] - '0';
    checkDigit += (i & 0x01) == 0 ? 3 * digit : digit;
  }

  checkDigit = 10 - (checkDigit % 10);
  if (checkDigit == 10) {
    checkDigit = 0;
  }
  [buf append:checkDigit];
}

@end

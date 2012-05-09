#import "ZXAI01decoder.h"
#import "ZXBitArray.h"
#import "ZXGeneralAppIdDecoder.h"

int const gtinSize = 40;

@interface ZXAI01decoder ()

- (void)appendCheckDigit:(NSMutableString *)buf currentPos:(int)currentPos;

@end


@implementation ZXAI01decoder

- (void)encodeCompressedGtin:(NSMutableString *)buf currentPos:(int)currentPos {
  [buf appendString:@"(01)"];
  int initialPosition = [buf length];
  [buf appendString:@"9"];

  [self encodeCompressedGtinWithoutAI:buf currentPos:currentPos initialBufferPosition:initialPosition];
}

- (void)encodeCompressedGtinWithoutAI:(NSMutableString *)buf currentPos:(int)currentPos initialBufferPosition:(int)initialBufferPosition {
  for (int i = 0; i < 4; ++i) {
    int currentBlock = [self.generalDecoder extractNumericValueFromBitArray:currentPos + 10 * i bits:10];
    if (currentBlock / 100 == 0) {
      [buf appendString:@"0"];
    }
    if (currentBlock / 10 == 0) {
      [buf appendString:@"0"];
    }
    [buf appendFormat:@"%d", currentBlock];
  }

  [self appendCheckDigit:buf currentPos:initialBufferPosition];
}

- (void)appendCheckDigit:(NSMutableString *)buf currentPos:(int)currentPos {
  int checkDigit = 0;
  for (int i = 0; i < 13; i++) {
    int digit = [buf characterAtIndex:i + currentPos] - '0';
    checkDigit += (i & 0x01) == 0 ? 3 * digit : digit;
  }

  checkDigit = 10 - (checkDigit % 10);
  if (checkDigit == 10) {
    checkDigit = 0;
  }

  [buf appendFormat:@"%d", checkDigit];
}

@end

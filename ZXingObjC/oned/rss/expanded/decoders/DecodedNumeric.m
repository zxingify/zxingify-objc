#import "DecodedNumeric.h"

int const FNC1 = 10;

@implementation DecodedNumeric

@synthesize firstDigit, secondDigit;

- (id) initWithNewPosition:(int)newPosition firstDigit:(int)aFirstDigit secondDigit:(int)aSecondDigit {
  if (self = [super initWithNewPosition:newPosition]) {
    firstDigit = aFirstDigit;
    secondDigit = aSecondDigit;

    if (firstDigit < 0 || firstDigit > 10) {
      [NSException raise:NSInvalidArgumentException format:@"Invalid firstDigit: %d", firstDigit];
    }

    if (secondDigit < 0 || secondDigit > 10) {
      [NSException raise:NSInvalidArgumentException format:@"Invalid secondDigit: %d", secondDigit];
    }
  }
  return self;
}

- (int) value {
  return firstDigit * 10 + secondDigit;
}

- (BOOL) firstDigitFNC1 {
  return firstDigit == FNC1;
}

- (BOOL) secondDigitFNC1 {
  return secondDigit == FNC1;
}

- (BOOL) anyFNC1 {
  return firstDigit == FNC1 || secondDigit == FNC1;
}

@end

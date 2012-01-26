#import "DecodedNumeric.h"

int const FNC1 = 10;

@implementation DecodedNumeric

- (id) init:(int)newPosition firstDigit:(int)firstDigit secondDigit:(int)secondDigit {
  if (self = [super init:newPosition]) {
    firstDigit = firstDigit;
    secondDigit = secondDigit;
    if (firstDigit < 0 || firstDigit > 10) {
      @throw [[[IllegalArgumentException alloc] init:[@"Invalid firstDigit: " stringByAppendingString:firstDigit]] autorelease];
    }
    if (secondDigit < 0 || secondDigit > 10) {
      @throw [[[IllegalArgumentException alloc] init:[@"Invalid secondDigit: " stringByAppendingString:secondDigit]] autorelease];
    }
  }
  return self;
}

- (int) getFirstDigit {
  return firstDigit;
}

- (int) getSecondDigit {
  return secondDigit;
}

- (int) getValue {
  return firstDigit * 10 + secondDigit;
}

- (BOOL) isFirstDigitFNC1 {
  return firstDigit == FNC1;
}

- (BOOL) isSecondDigitFNC1 {
  return secondDigit == FNC1;
}

- (BOOL) isAnyFNC1 {
  return firstDigit == FNC1 || secondDigit == FNC1;
}

@end

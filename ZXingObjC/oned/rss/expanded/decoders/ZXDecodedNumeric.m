#import "ZXDecodedNumeric.h"

const int FNC1 = 10;

@interface ZXDecodedNumeric ()

@property (nonatomic, assign) int firstDigit;
@property (nonatomic, assign) int secondDigit;

@end


@implementation ZXDecodedNumeric

@synthesize firstDigit;
@synthesize secondDigit;

- (id)initWithNewPosition:(int)newPosition firstDigit:(int)aFirstDigit secondDigit:(int)aSecondDigit {
  if (self = [super initWithNewPosition:newPosition]) {
    self.firstDigit = aFirstDigit;
    self.secondDigit = aSecondDigit;

    if (self.firstDigit < 0 || self.firstDigit > 10) {
      [NSException raise:NSInvalidArgumentException format:@"Invalid firstDigit: %d", firstDigit];
    }

    if (self.secondDigit < 0 || self.secondDigit > 10) {
      [NSException raise:NSInvalidArgumentException format:@"Invalid secondDigit: %d", secondDigit];
    }
  }

  return self;
}

- (int)value {
  return self.firstDigit * 10 + self.secondDigit;
}

- (BOOL)firstDigitFNC1 {
  return self.firstDigit == FNC1;
}

- (BOOL)secondDigitFNC1 {
  return self.secondDigit == FNC1;
}

- (BOOL)anyFNC1 {
  return self.firstDigit == FNC1 || self.secondDigit == FNC1;
}

@end

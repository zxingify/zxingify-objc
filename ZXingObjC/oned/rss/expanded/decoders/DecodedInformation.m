#import "DecodedInformation.h"

@implementation DecodedInformation

- (id) init:(int)newPosition newString:(NSString *)newString {
  if (self = [super init:newPosition]) {
    newString = newString;
    remaining = NO;
    remainingValue = 0;
  }
  return self;
}

- (id) init:(int)newPosition newString:(NSString *)newString remainingValue:(int)remainingValue {
  if (self = [super init:newPosition]) {
    remaining = YES;
    remainingValue = remainingValue;
    newString = newString;
  }
  return self;
}

- (NSString *) getNewString {
  return newString;
}

- (BOOL) isRemaining {
  return remaining;
}

- (int) getRemainingValue {
  return remainingValue;
}

- (void) dealloc {
  [newString release];
  [super dealloc];
}

@end

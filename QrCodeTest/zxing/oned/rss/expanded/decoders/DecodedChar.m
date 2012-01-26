#import "DecodedChar.h"

unichar const FNC1 = '$';

@implementation DecodedChar

- (id) init:(int)newPosition value:(unichar)value {
  if (self = [super init:newPosition]) {
    value = value;
  }
  return self;
}

- (unichar) getValue {
  return value;
}

- (BOOL) isFNC1 {
  return value == FNC1;
}

@end

#import "DecodedChar.h"

unichar const FNC1 = '$';

@implementation DecodedChar

@synthesize value;

- (id) initWithNewPosition:(int)aNewPosition value:(unichar)aValue {
  if (self = [super initWithNewPosition:aNewPosition]) {
    value = aValue;
  }
  return self;
}

- (BOOL) fnc1 {
  return value == FNC1;
}

@end

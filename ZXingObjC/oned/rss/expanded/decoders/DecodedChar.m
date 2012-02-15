#import "DecodedChar.h"

unichar const FNC1 = '$';

@implementation DecodedChar

- (id) initWithNewPosition:(int)aNewPosition value:(unichar)aValue {
  if (self = [super initWithNewPosition:aNewPosition]) {
    value = aValue;
  }
  return self;
}

- (BOOL) isFNC1 {
  return value == FNC1;
}

@end

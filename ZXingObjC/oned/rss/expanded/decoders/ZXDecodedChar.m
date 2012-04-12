#import "ZXDecodedChar.h"

unichar const FNC1char = '$';

@implementation ZXDecodedChar

@synthesize value;

- (id) initWithNewPosition:(int)aNewPosition value:(unichar)aValue {
  if (self = [super initWithNewPosition:aNewPosition]) {
    value = aValue;
  }
  return self;
}

- (BOOL) fnc1 {
  return value == FNC1char;
}

@end

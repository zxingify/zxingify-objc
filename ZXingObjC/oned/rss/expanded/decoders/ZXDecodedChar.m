#import "ZXDecodedChar.h"

unichar const FNC1char = '$';

@interface ZXDecodedChar ()

@property (nonatomic, assign) unichar value;

@end

@implementation ZXDecodedChar

@synthesize value;

- (id) initWithNewPosition:(int)aNewPosition value:(unichar)aValue {
  if (self = [super initWithNewPosition:aNewPosition]) {
    self.value = aValue;
  }

  return self;
}

- (BOOL)fnc1 {
  return self.value == FNC1char;
}

@end

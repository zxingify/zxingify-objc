#import "CharacterSetECI.h"
#import "ECI.h"

@implementation ECI

@synthesize value;

- (id) initWithValue:(int)aValue {
  if (self = [super init]) {
    self.value = aValue;
  }
  return self;
}


/**
 * @param value ECI value
 * @return ECI representing ECI of given value, or null if it is legal but unsupported
 * @throws IllegalArgumentException if ECI value is invalid
 */
+ (ECI *) getECIByValue:(int)value {
  if (value < 0 || value > 999999) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"Bad ECI value: %d", value]
                                 userInfo:nil];
  }
  if (value < 900) {
    return [CharacterSetECI getCharacterSetECIByValue:value];
  }
  return nil;
}

@end

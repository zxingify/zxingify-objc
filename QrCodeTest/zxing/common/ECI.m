#import "ECI.h"

@implementation ECI

@synthesize value;

- (id) initWithValue:(int)value {
  if (self = [super init]) {
    value = value;
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
    @throw [[[IllegalArgumentException alloc] init:[@"Bad ECI value: " stringByAppendingString:value]] autorelease];
  }
  if (value < 900) {
    return [CharacterSetECI getCharacterSetECIByValue:value];
  }
  return nil;
}

@end

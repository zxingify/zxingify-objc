#import "ZXDataCharacter.h"

@implementation ZXDataCharacter

@synthesize value;
@synthesize checksumPortion;

- (id) initWithValue:(int)aValue checksumPortion:(int)aChecksumPortion {
  if (self = [super init]) {
    value = aValue;
    checksumPortion = aChecksumPortion;
  }
  return self;
}

@end

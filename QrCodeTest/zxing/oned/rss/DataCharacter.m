#import "DataCharacter.h"

@implementation DataCharacter

@synthesize value;
@synthesize checksumPortion;

- (id) init:(int)value checksumPortion:(int)checksumPortion {
  if (self = [super init]) {
    value = value;
    checksumPortion = checksumPortion;
  }
  return self;
}

@end

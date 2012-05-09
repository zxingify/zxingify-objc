#import "ZXDataCharacter.h"

@interface ZXDataCharacter ()

@property (nonatomic, assign) int value;
@property (nonatomic, assign) int checksumPortion;

@end

@implementation ZXDataCharacter

@synthesize value;
@synthesize checksumPortion;

- (id)initWithValue:(int)aValue checksumPortion:(int)aChecksumPortion {
  if (self = [super init]) {
    self.value = aValue;
    self.checksumPortion = aChecksumPortion;
  }

  return self;
}

@end

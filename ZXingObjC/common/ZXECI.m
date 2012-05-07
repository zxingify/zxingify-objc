#import "ZXCharacterSetECI.h"
#import "ZXECI.h"

@interface ZXECI ()

@property (nonatomic) int value;

@end


@implementation ZXECI

@synthesize value;

- (id)initWithValue:(int)aValue {
  self = [super init];
  if (self) {
    self.value = aValue;
  }

  return self;
}


+ (ZXECI *)eciByValue:(int)value {
  if (value < 0 || value > 999999) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"Bad ECI value: %d", value]
                                 userInfo:nil];
  }
  if (value < 900) {
    return [ZXCharacterSetECI characterSetECIByValue:value];
  }
  return nil;
}

@end

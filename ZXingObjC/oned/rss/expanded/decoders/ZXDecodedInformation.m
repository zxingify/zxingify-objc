#import "ZXDecodedInformation.h"

@interface ZXDecodedInformation ()

@property (nonatomic, copy) NSString * theNewString;
@property (nonatomic, assign) int remainingValue;
@property (nonatomic, assign) BOOL remaining;

@end

@implementation ZXDecodedInformation

@synthesize remaining;
@synthesize remainingValue;
@synthesize theNewString;

- (id)initWithNewPosition:(int)aNewPosition newString:(NSString *)aNewString {
  return [self initWithNewPosition:aNewPosition newString:aNewString remainingValue:0];
}

- (id)initWithNewPosition:(int)aNewPosition newString:(NSString *)aNewString remainingValue:(int)aRemainingValue {
  if (self = [super initWithNewPosition:aNewPosition]) {
    self.remaining = YES;
    self.remainingValue = aRemainingValue;
    self.theNewString = aNewString;
  }

  return self;
}

- (void)dealloc {
  [theNewString release];

  [super dealloc];
}

@end

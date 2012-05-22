#import "FalsePositives2BlackBoxTestCase.h"
#import "ZXMultiFormatReader.h"

@implementation FalsePositives2BlackBoxTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation testBasePathSuffix:@"Resources/blackbox/falsepositives-2"];

  if (self) {
    [self addTest:7 rotation:0.0f];
    [self addTest:7 rotation:90.0f];
    [self addTest:7 rotation:180.0f];
    [self addTest:7 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

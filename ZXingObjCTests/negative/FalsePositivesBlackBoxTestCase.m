#import "FalsePositivesBlackBoxTestCase.h"
#import "ZXMultiFormatReader.h"

@implementation FalsePositivesBlackBoxTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation testBasePathSuffix:@"Resources/blackbox/falsepositives"];

  if (self) {
    [self addTest:1 rotation:0.0f];
    [self addTest:0 rotation:90.0f];
    [self addTest:0 rotation:180.0f];
    [self addTest:1 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

#import "AztecBlackBox1TestCase.h"
#import "ZXAztecReader.h"

@implementation AztecBlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/aztec-1"
                     barcodeReader:[[[ZXAztecReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatAztec];

  if (self) {
    [self addTest:7 tryHarderCount:7 rotation:0.0f];
    [self addTest:7 tryHarderCount:7 rotation:90.0f];
    [self addTest:7 tryHarderCount:7 rotation:180.0f];
    [self addTest:7 tryHarderCount:7 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

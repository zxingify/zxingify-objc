#import "Code39ExtendedBlackBox2TestCase.h"
#import "ZXCode39Reader.h"

@implementation Code39ExtendedBlackBox2TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/code39-2"
                     barcodeReader:[[[ZXCode39Reader alloc] initUsingCheckDigit:NO extendedMode:YES] autorelease]
                    expectedFormat:kBarcodeFormatCode39];

  if (self) {
    [self addTest:2 tryHarderCount:2 rotation:0.0f];
    [self addTest:2 tryHarderCount:2 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

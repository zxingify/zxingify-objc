#import "AztecBlackBox2TestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXMultiFormatReader.h"

@implementation AztecBlackBox2TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/aztec-2"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatAztec];

  if (self) {
    [self addTest:2 tryHarderCount:2 rotation:0.0f];
    [self addTest:2 tryHarderCount:2 rotation:90.0f];
    [self addTest:3 tryHarderCount:3 rotation:180.0f];
    [self addTest:1 tryHarderCount:1 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

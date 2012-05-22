#import "ITFBlackBox2TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation ITFBlackBox2TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/itf-2"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatITF];

  if (self) {
    [self addTest:8 tryHarderCount:9 rotation:0.0f];
    [self addTest:7 tryHarderCount:9 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

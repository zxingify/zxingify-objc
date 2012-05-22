#import "UPCABlackBox2TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation UPCABlackBox2TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/upca-2"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatUPCA];

  if (self) {
    [self addTest:29 tryHarderCount:35 rotation:0.0f];
    [self addTest:31 tryHarderCount:35 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

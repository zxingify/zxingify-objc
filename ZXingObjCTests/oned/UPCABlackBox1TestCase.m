#import "UPCABlackBox1TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation UPCABlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/upca-1"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatUPCA];

  if (self) {
    [self addTest:14 tryHarderCount:18 rotation:0.0f];
    [self addTest:16 tryHarderCount:18 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

#import "UPCABlackBox4TestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXMultiFormatReader.h"

@implementation UPCABlackBox4TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/upca-4"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatUPCA];

  if (self) {
    // NOTE (costa@scvngr.com) The java version of ZXing has 9 and 11
    [self addTest:10 tryHarderCount:13 rotation:0.0f];

    // NOTE (costa@scvngr.com) The java version of ZXing has 9 and 11
    [self addTest:8 tryHarderCount:13 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

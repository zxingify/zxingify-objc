#import "EAN13BlackBox4TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation EAN13BlackBox4TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/ean13-4"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatEan13];

  if (self) {
    // NOTE (costa@scvngr.com) The java version of ZXing has 6 and 13
    [self addTest:5 tryHarderCount:12 rotation:0.0f];

    // NOTE (costa@scvngr.com) The java version of ZXing has 7 and 13
    [self addTest:7 tryHarderCount:12 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

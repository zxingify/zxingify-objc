#import "UPCABlackBox3ReflectiveTestCase.h"
#import "ZXMultiFormatReader.h"

@implementation UPCABlackBox3ReflectiveTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/upca-3"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatUPCA];

  if (self) {
    // NOTE (costa@scvngr.com) The java version of ZXing has 7 and 8
    [self addTest:6 tryHarderCount:8 rotation:0.0f];

    [self addTest:8 tryHarderCount:9 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

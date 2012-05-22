#import "UPCEANExtensionBlackBox1TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation UPCEANExtensionBlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/upcean-extension-1"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatEan13];

  if (self) {
    [self addTest:2 tryHarderCount:2 rotation:0.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

#import "UPCABlackBox6BlurryTestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXMultiFormatReader.h"

@implementation UPCABlackBox6BlurryTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/upca-6"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatUPCA];

  if (self) {
    [self addTest:0 tryHarderCount:0 rotation:0.0f];
    [self addTest:0 tryHarderCount:0 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

#import "EAN13BlackBox5BlurryTestCase.h"
#import "ZXMultiFormatReader.h"

@implementation EAN13BlackBox5BlurryTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/ean13-5"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatEan13];

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

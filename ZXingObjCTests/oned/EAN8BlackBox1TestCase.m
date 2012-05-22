#import "EAN8BlackBox1TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation EAN8BlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/ean8-1"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatEan8];

  if (self) {
    [self addTest:8 tryHarderCount:8 rotation:0.0f];
    [self addTest:8 tryHarderCount:8 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

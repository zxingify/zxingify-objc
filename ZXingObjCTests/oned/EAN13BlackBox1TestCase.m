#import "EAN13BlackBox1TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation EAN13BlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/ean13-1"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatEan13];

  if (self) {
    [self addTest:29 tryHarderCount:32 rotation:0.0f];
    [self addTest:28 tryHarderCount:32 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

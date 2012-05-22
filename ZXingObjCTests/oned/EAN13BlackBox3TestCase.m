#import "EAN13BlackBox3TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation EAN13BlackBox3TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/ean13-3"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatEan13];

  if (self) {
    [self addTest:53 tryHarderCount:55 rotation:0.0f];
    [self addTest:55 tryHarderCount:55 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

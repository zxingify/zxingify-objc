#import "DataMatrixBlackBox2TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation DataMatrixBlackBox2TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/datamatrix-2"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatDataMatrix];

  if (self) {
    [self addTest:10 tryHarderCount:10 rotation:0.0f];
    [self addTest:13 tryHarderCount:13 rotation:90.0f];
    [self addTest:16 tryHarderCount:16 rotation:180.0f];
    [self addTest:13 tryHarderCount:13 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

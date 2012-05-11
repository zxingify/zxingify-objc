#import "DataMatrixBlackBox1TestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXMultiFormatReader.h"

@implementation DataMatrixBlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/datamatrix-1"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatDataMatrix];

  if (self) {
    [self addTest:18 tryHarderCount:18 rotation:0.0f];
    [self addTest:18 tryHarderCount:18 rotation:90.0f];
    [self addTest:18 tryHarderCount:18 rotation:180.0f];
    [self addTest:18 tryHarderCount:18 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

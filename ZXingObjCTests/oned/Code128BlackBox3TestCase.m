#import "Code128BlackBox3TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation Code128BlackBox3TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/code128-3"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatCode128];

  if (self) {
    [self addTest:2 tryHarderCount:2 rotation:0.0f];
    [self addTest:2 tryHarderCount:2 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

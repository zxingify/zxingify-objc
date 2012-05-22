#import "Code128BlackBox2TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation Code128BlackBox2TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/code128-2"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatCode128];

  if (self) {
    [self addTest:36 tryHarderCount:39 rotation:0.0f];
    [self addTest:36 tryHarderCount:39 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

#import "Code39BlackBox3TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation Code39BlackBox3TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/code39-3"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatCode39];

  if (self) {
    [self addTest:17 tryHarderCount:17 rotation:0.0f];
    [self addTest:17 tryHarderCount:17 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

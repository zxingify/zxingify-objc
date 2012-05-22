#import "ITFBlackBox1TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation ITFBlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/itf-1"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatITF];

  if (self) {
    [self addTest:8 tryHarderCount:12 rotation:0.0f];
    [self addTest:11 tryHarderCount:12 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

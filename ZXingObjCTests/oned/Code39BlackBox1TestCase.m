#import "Code39BlackBox1TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation Code39BlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/code39-1"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatCode39];

  if (self) {
    [self addTest:4 tryHarderCount:4 rotation:0.0f];
    [self addTest:4 tryHarderCount:4 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

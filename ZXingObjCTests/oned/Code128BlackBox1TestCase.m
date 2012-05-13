#import "Code128BlackBox1TestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXMultiFormatReader.h"

@implementation Code128BlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/code128-1"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatCode128];

  if (self) {
    [self addTest:5 tryHarderCount:5 rotation:0.0f];
    [self addTest:5 tryHarderCount:5 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

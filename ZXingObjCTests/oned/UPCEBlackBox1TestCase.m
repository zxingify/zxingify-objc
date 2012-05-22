#import "UPCEBlackBox1TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation UPCEBlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/upce-1"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatUPCE];

  if (self) {
    [self addTest:3 tryHarderCount:3 rotation:0.0f];
    [self addTest:3 tryHarderCount:3 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

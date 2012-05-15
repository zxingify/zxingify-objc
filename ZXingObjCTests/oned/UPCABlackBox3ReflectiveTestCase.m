#import "UPCABlackBox3ReflectiveTestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXMultiFormatReader.h"

@implementation UPCABlackBox3ReflectiveTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/upca-3"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatUPCA];

  if (self) {
    [self addTest:7 tryHarderCount:8 rotation:0.0f];
    [self addTest:8 tryHarderCount:9 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

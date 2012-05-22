#import "UPCEBlackBox3ReflectiveTestCase.h"
#import "ZXMultiFormatReader.h"

@implementation UPCEBlackBox3ReflectiveTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/upce-3"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatUPCE];

  if (self) {
    [self addTest:6 tryHarderCount:8 rotation:0.0f];
    [self addTest:6 tryHarderCount:8 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

#import "QRCodeBlackBox4TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation QRCodeBlackBox4TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/qrcode-4"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatQRCode];

  if (self) {
    [self addTest:36 tryHarderCount:36 rotation:0.0f];
    [self addTest:36 tryHarderCount:36 rotation:90.0f];
    [self addTest:35 tryHarderCount:35 rotation:180.0f];
    [self addTest:35 tryHarderCount:35 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

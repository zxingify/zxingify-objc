#import "QRCodeBlackBox3TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation QRCodeBlackBox3TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/qrcode-3"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatQRCode];

  if (self) {
    [self addTest:38 tryHarderCount:38 rotation:0.0f];
    [self addTest:38 tryHarderCount:38 rotation:90.0f];
    [self addTest:36 tryHarderCount:36 rotation:180.0f];
    [self addTest:38 tryHarderCount:38 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

#import "QRCodeBlackBox2TestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXMultiFormatReader.h"

@implementation QRCodeBlackBox2TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/qrcode-2"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatQRCode];

  if (self) {
    [self addTest:29 tryHarderCount:29 rotation:0.0f];
    [self addTest:29 tryHarderCount:29 rotation:90.0f];
    [self addTest:29 tryHarderCount:29 rotation:180.0f];
    [self addTest:28 tryHarderCount:28 rotation:270.0f];
  }

  return self;
}

- (void) testBlackBox {
  [super testBlackBox];
}

@end

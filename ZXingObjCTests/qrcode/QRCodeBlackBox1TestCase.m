#import "QRCodeBlackBox1TestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXMultiFormatReader.h"

@implementation QRCodeBlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/qrcode-1"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatQRCode];

  if (self) {
    [self addTest:17 tryHarderCount:17 rotation:0.0f];
    [self addTest:13 tryHarderCount:13 rotation:90.0f];
    [self addTest:16 tryHarderCount:16 rotation:180.0f];
    [self addTest:14 tryHarderCount:14 rotation:270.0f];
  }

  return self;
}

- (void) testBlackBox {
  [super runTests];
}

@end

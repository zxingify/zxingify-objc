#import "QRCodeBlackBox6TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation QRCodeBlackBox6TestCase

/**
 * These tests are supplied by Tim Gernat and test finder pattern detection at small size and under
 * rotation, which was a weak spot.
 */
- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/qrcode-6"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatQRCode];

  if (self) {
    [self addTest:14 tryHarderCount:14 rotation:0.0f];
    [self addTest:13 tryHarderCount:13 rotation:90.0f];
    [self addTest:11 tryHarderCount:12 rotation:180.0f];
    [self addTest:13 tryHarderCount:13 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

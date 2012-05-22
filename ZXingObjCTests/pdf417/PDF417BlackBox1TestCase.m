#import "PDF417BlackBox1TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation PDF417BlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/pdf417"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatPDF417];

  if (self) {
    [self addTest:3 tryHarderCount:3 rotation:0.0f];
    [self addTest:3 tryHarderCount:3 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

- (ZXDecodeHints *)hints {
  ZXDecodeHints* hints = [[[ZXDecodeHints alloc] init] autorelease];
  [hints addPossibleFormat:kBarcodeFormatPDF417];
  return hints;
}

@end

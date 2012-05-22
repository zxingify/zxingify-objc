#import "RSS14BlackBox2TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation RSS14BlackBox2TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/rss14-2"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatRSS14];

  if (self) {
    [self addTest:0 tryHarderCount:8 rotation:0.0f];
    [self addTest:0 tryHarderCount:8 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

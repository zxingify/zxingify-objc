#import "RSS14BlackBox1TestCase.h"
#import "ZXMultiFormatReader.h"

@implementation RSS14BlackBox1TestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation
                testBasePathSuffix:@"Resources/blackbox/rss14-1"
                     barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease]
                    expectedFormat:kBarcodeFormatRSS14];

  if (self) {
    [self addTest:6 tryHarderCount:6 rotation:0.0f];
    [self addTest:6 tryHarderCount:6 rotation:180.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

#import "PartialBlackBoxTestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXMultiFormatReader.h"

/**
 * This test ensures that partial barcodes do not decode.
 */
@implementation PartialBlackBoxTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation testBasePathSuffix:@"Resources/blackbox/partial"];

  if (self) {
    [self addTest:1 rotation:0.0f];
    [self addTest:1 rotation:90.0f];
    [self addTest:1 rotation:180.0f];
    [self addTest:1 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

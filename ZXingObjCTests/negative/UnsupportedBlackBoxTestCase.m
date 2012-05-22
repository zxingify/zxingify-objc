#import "UnsupportedBlackBoxTestCase.h"
#import "ZXMultiFormatReader.h"

/**
 * This test ensures that unsupported barcodes do not decode.
 */
@implementation UnsupportedBlackBoxTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation testBasePathSuffix:@"Resources/blackbox/unsupported"];

  if (self) {
    [self addTest:0 rotation:0.0f];
    [self addTest:0 rotation:90.0f];
    [self addTest:0 rotation:180.0f];
    [self addTest:0 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end

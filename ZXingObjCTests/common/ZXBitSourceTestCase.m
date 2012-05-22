#import "ZXBitSource.h"
#import "ZXBitSourceTestCase.h"

@implementation ZXBitSourceTestCase

- (void)testSource {
  unsigned char bytes[5] = {1, 2, 3, 4, 5};
  ZXBitSource* source = [[[ZXBitSource alloc] initWithBytes:bytes length:5] autorelease];
  STAssertEquals(source.available, 40, @"Expected source.available to 40");
  STAssertEquals([source readBits:1], 0, @"Expected [source readBits:1] to 0");
  STAssertEquals(source.available, 39, @"Expected source.available to 39");
  STAssertEquals([source readBits:6], 0, @"Expected [source readBits:6] to 0");
  STAssertEquals(source.available, 33, @"Expected source.available to 33");
  STAssertEquals([source readBits:1], 1, @"Expected [source readBits:1] to 1");
  STAssertEquals(source.available, 32, @"Expected source.available to 32");
  STAssertEquals([source readBits:8], 2, @"Expected [source readBits:1] to 1");
  STAssertEquals(source.available, 24, @"Expected source.available to 24");
  STAssertEquals([source readBits:10], 12, @"Expected [source readBits:10] to 1");
  STAssertEquals(source.available, 14, @"Expected source.available to 14");
  STAssertEquals([source readBits:8], 16, @"Expected [source readBits:8] to 16");
  STAssertEquals(source.available, 6, @"Expected source.available to 6");
  STAssertEquals([source readBits:6], 5, @"Expected [source readBits:6] to 5");
  STAssertEquals(source.available, 0, @"Expected source.available to 0");
}

@end

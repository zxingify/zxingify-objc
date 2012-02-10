#import "AI013x0xDecoder.h"

int const headerSize = 4 + 1;
int const weightSize = 15;

@implementation AI013x0xDecoder

- (id) initWithInformation:(BitArray *)information {
  if (self = [super init:information]) {
  }
  return self;
}

- (NSString *) parseInformation {
  if (information.size != headerSize + gtinSize + weightSize) {
    @throw [NotFoundException notFoundInstance];
  }
  NSMutableString * buf = [[[NSMutableString alloc] init] autorelease];
  [self encodeCompressedGtin:buf param1:headerSize];
  [self encodeCompressedWeight:buf param1:headerSize + gtinSize param2:weightSize];
  return [buf description];
}

@end

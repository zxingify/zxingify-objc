#import "AI013x0xDecoder.h"
#import "BitArray.h"
#import "NotFoundException.h"

int const AI013x0xHeaderSize = 4 + 1;
int const AI013x0xWeightSize = 15;

@implementation AI013x0xDecoder

- (NSString *) parseInformation {
  if (information.size != AI013x0xHeaderSize + gtinSize + AI013x0xWeightSize) {
    @throw [NotFoundException notFoundInstance];
  }

  NSMutableString * buf = [NSMutableString string];

  [self encodeCompressedGtin:buf currentPos:AI013x0xHeaderSize];
  [self encodeCompressedWeight:buf currentPos:AI013x0xHeaderSize + gtinSize weightSize:AI013x0xWeightSize];

  return buf;
}

@end

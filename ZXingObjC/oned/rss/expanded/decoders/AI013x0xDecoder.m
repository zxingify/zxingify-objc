#import "AI013x0xDecoder.h"
#import "BitArray.h"
#import "NotFoundException.h"

int const headerSize = 4 + 1;
int const weightSize = 15;

@implementation AI013x0xDecoder

- (NSString *) parseInformation {
  if (information.size != headerSize + gtinSize + weightSize) {
    @throw [NotFoundException notFoundInstance];
  }

  NSMutableString * buf = [NSMutableString string];

  [self encodeCompressedGtin:buf currentPos:headerSize];
  [self encodeCompressedWeight:buf currentPos:headerSize + gtinSize weightSize:weightSize];

  return buf;
}

@end

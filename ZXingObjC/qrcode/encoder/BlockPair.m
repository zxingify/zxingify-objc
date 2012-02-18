#import "BlockPair.h"

@implementation BlockPair

@synthesize dataBytes;
@synthesize errorCorrectionBytes;

- (id) initWithData:(char *)data errorCorrection:(char *)errorCorrection {
  if (self = [super init]) {
    dataBytes = data;
    errorCorrectionBytes = errorCorrection;
  }
  return self;
}

@end

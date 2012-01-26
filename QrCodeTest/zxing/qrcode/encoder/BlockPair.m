#import "BlockPair.h"

@implementation BlockPair

@synthesize dataBytes;
@synthesize errorCorrectionBytes;

- (id) init:(NSArray *)data errorCorrection:(NSArray *)errorCorrection {
  if (self = [super init]) {
    dataBytes = data;
    errorCorrectionBytes = errorCorrection;
  }
  return self;
}

- (void) dealloc {
  [dataBytes release];
  [errorCorrectionBytes release];
  [super dealloc];
}

@end

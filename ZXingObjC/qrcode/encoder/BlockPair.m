#import "BlockPair.h"

@implementation BlockPair

@synthesize dataBytes;
@synthesize errorCorrectionBytes;
@synthesize errorCorrectionLength;
@synthesize length;

- (id) initWithData:(unsigned char *)data length:(unsigned int)aLength errorCorrection:(unsigned char *)errorCorrection errorCorrectionLength:(unsigned int)anErrorCorrectionLength{
  if (self = [super init]) {
    dataBytes = data;
    errorCorrectionBytes = errorCorrection;
    length = aLength;
    errorCorrectionLength = anErrorCorrectionLength;
  }
  return self;
}

@end

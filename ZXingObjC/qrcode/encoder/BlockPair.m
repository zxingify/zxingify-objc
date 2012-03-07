#import "BlockPair.h"

@implementation BlockPair

@synthesize dataBytes;
@synthesize errorCorrectionBytes;
@synthesize errorCorrectionLength;
@synthesize length;

- (id) initWithData:(unsigned char *)data length:(unsigned int)aLength errorCorrection:(unsigned char *)errorCorrection errorCorrectionLength:(unsigned int)anErrorCorrectionLength{
  if (self = [super init]) {
    dataBytes = (unsigned char*)malloc(aLength * sizeof(char));
    memcpy(dataBytes, data, aLength * sizeof(char));
    errorCorrectionBytes = (unsigned char*)malloc(anErrorCorrectionLength * sizeof(char));
    memcpy(errorCorrectionBytes, errorCorrection, anErrorCorrectionLength);
    length = aLength;
    errorCorrectionLength = anErrorCorrectionLength;
  }
  return self;
}

- (void)dealloc {
  free(dataBytes);
  free(errorCorrectionBytes);
  [super dealloc];
}

@end

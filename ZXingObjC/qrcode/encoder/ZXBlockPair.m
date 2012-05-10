#import "ZXBlockPair.h"

@interface ZXBlockPair ()

@property (nonatomic, assign) unsigned char * dataBytes;
@property (nonatomic, assign) unsigned char * errorCorrectionBytes;
@property (nonatomic, assign) int errorCorrectionLength;
@property (nonatomic, assign) int length;

@end

@implementation ZXBlockPair

@synthesize dataBytes;
@synthesize errorCorrectionBytes;
@synthesize errorCorrectionLength;
@synthesize length;

- (id)initWithData:(unsigned char *)data length:(unsigned int)aLength errorCorrection:(unsigned char *)errorCorrection errorCorrectionLength:(unsigned int)anErrorCorrectionLength{
  if (self = [super init]) {
    self.dataBytes = (unsigned char*)malloc(aLength * sizeof(char));
    memcpy(self.dataBytes, data, aLength * sizeof(char));
    self.errorCorrectionBytes = (unsigned char*)malloc(anErrorCorrectionLength * sizeof(char));
    memcpy(self.errorCorrectionBytes, errorCorrection, anErrorCorrectionLength);
    self.length = aLength;
    self.errorCorrectionLength = anErrorCorrectionLength;
  }

  return self;
}

- (void)dealloc {
  if (self.dataBytes != NULL) {
    free(self.dataBytes);
    self.dataBytes = NULL;
  }

  if (self.errorCorrectionBytes != NULL) {
    free(self.errorCorrectionBytes);
    self.errorCorrectionBytes = NULL;
  }

  [super dealloc];
}

@end

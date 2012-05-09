#import "ZXCurrentParsingState.h"

int const NUMERIC_STATE = 1;
int const ALPHA_STATE = 2;
int const ISO_IEC_646_STATE = 4;

@interface ZXCurrentParsingState ()

@property (nonatomic, assign) int encoding;

@end

@implementation ZXCurrentParsingState

@synthesize encoding;
@synthesize position;

- (id)init {
  if (self = [super init]) {
    self.position = 0;
    self.encoding = NUMERIC_STATE;
  }
  return self;
}

- (BOOL)alpha {
  return self.encoding == ALPHA_STATE;
}

- (BOOL)numeric {
  return self.encoding == NUMERIC_STATE;
}

- (BOOL)isoIec646 {
  return self.encoding == ISO_IEC_646_STATE;
}

- (void)setNumeric {
  self.encoding = NUMERIC_STATE;
}

- (void)setAlpha {
  self.encoding = ALPHA_STATE;
}

- (void)setIsoIec646 {
  self.encoding = ISO_IEC_646_STATE;
}

@end

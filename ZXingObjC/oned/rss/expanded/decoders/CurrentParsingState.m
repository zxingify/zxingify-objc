#import "CurrentParsingState.h"

int const NUMERIC_STATE = 1;
int const ALPHA_STATE = 2;
int const ISO_IEC_646_STATE = 4;

@implementation CurrentParsingState

@synthesize position;

- (id) init {
  if (self = [super init]) {
    position = 0;
    encoding = NUMERIC_STATE;
  }
  return self;
}

- (BOOL) alpha {
  return encoding == ALPHA_STATE;
}

- (BOOL) numeric {
  return encoding == NUMERIC_STATE;
}

- (BOOL) isoIec646 {
  return encoding == ISO_IEC_646_STATE;
}

- (void) setNumeric {
  encoding = NUMERIC_STATE;
}

- (void) setAlpha {
  encoding = ALPHA_STATE;
}

- (void) setIsoIec646 {
  encoding = ISO_IEC_646_STATE;
}

@end

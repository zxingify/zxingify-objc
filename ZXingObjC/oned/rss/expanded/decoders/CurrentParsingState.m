#import "CurrentParsingState.h"

int const NUMERIC = 1;
int const ALPHA = 2;
int const ISO_IEC_646 = 4;

@implementation CurrentParsingState

@synthesize position;

- (id) init {
  if (self = [super init]) {
    position = 0;
    encoding = NUMERIC;
  }
  return self;
}

- (BOOL) alpha {
  return encoding == ALPHA;
}

- (BOOL) numeric {
  return encoding == NUMERIC;
}

- (BOOL) isoIec646 {
  return encoding == ISO_IEC_646;
}

- (void) setNumeric {
  encoding = NUMERIC;
}

- (void) setAlpha {
  encoding = ALPHA;
}

- (void) setIsoIec646 {
  encoding = ISO_IEC_646;
}

@end

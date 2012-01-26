#import "CurrentParsingState.h"

int const NUMERIC = 1;
int const ALPHA = 2;
int const ISO_IEC_646 = 4;

@implementation CurrentParsingState

- (id) init {
  if (self = [super init]) {
    position = 0;
    encoding = NUMERIC;
  }
  return self;
}

- (BOOL) isAlpha {
  return encoding == ALPHA;
}

- (BOOL) isNumeric {
  return encoding == NUMERIC;
}

- (BOOL) isIsoIec646 {
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

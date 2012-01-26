#import "Pair.h"

@implementation Pair

- (id) init:(int)value checksumPortion:(int)checksumPortion finderPattern:(FinderPattern *)finderPattern {
  if (self = [super init:value param1:checksumPortion]) {
    finderPattern = finderPattern;
  }
  return self;
}

- (FinderPattern *) getFinderPattern {
  return finderPattern;
}

- (int) getCount {
  return count;
}

- (void) incrementCount {
  count++;
}

- (void) dealloc {
  [finderPattern release];
  [super dealloc];
}

@end

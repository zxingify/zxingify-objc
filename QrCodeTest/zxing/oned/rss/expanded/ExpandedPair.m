#import "ExpandedPair.h"

@implementation ExpandedPair

- (id) init:(DataCharacter *)leftChar rightChar:(DataCharacter *)rightChar finderPattern:(FinderPattern *)finderPattern mayBeLast:(BOOL)mayBeLast {
  if (self = [super init]) {
    leftChar = leftChar;
    rightChar = rightChar;
    finderPattern = finderPattern;
    mayBeLast = mayBeLast;
  }
  return self;
}

- (BOOL) mayBeLast {
  return mayBeLast;
}

- (DataCharacter *) getLeftChar {
  return leftChar;
}

- (DataCharacter *) getRightChar {
  return rightChar;
}

- (FinderPattern *) getFinderPattern {
  return finderPattern;
}

- (BOOL) mustBeLast {
  return rightChar == nil;
}

- (void) dealloc {
  [leftChar release];
  [rightChar release];
  [finderPattern release];
  [super dealloc];
}

@end

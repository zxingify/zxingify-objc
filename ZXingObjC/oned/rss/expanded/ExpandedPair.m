#import "ExpandedPair.h"
#import "DataCharacter.h"
#import "RSSFinderPattern.h"

@implementation ExpandedPair

@synthesize finderPattern;
@synthesize leftChar;
@synthesize mayBeLast;
@synthesize rightChar;

- (id) initWithLeftChar:(DataCharacter *)aLeftChar rightChar:(DataCharacter *)aRightChar
          finderPattern:(RSSFinderPattern *)aFinderPattern mayBeLast:(BOOL)aMayBeLast {
  if (self = [super init]) {
    leftChar = [aLeftChar retain];
    rightChar = [aRightChar retain];
    finderPattern = [aFinderPattern retain];
    mayBeLast = aMayBeLast;
  }
  return self;
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

#import "ZXExpandedPair.h"
#import "ZXDataCharacter.h"
#import "ZXRSSFinderPattern.h"

@implementation ZXExpandedPair

@synthesize finderPattern;
@synthesize leftChar;
@synthesize mayBeLast;
@synthesize rightChar;

- (id) initWithLeftChar:(ZXDataCharacter *)aLeftChar rightChar:(ZXDataCharacter *)aRightChar
          finderPattern:(ZXRSSFinderPattern *)aFinderPattern mayBeLast:(BOOL)aMayBeLast {
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

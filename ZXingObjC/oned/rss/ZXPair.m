#import "ZXRSSFinderPattern.h"
#import "ZXPair.h"

@implementation ZXPair

@synthesize count, finderPattern;

- (id) initWithValue:(int)aValue checksumPortion:(int)aChecksumPortion finderPattern:(ZXRSSFinderPattern *)aFinderPattern {
  if (self = [super initWithValue:aValue checksumPortion:aChecksumPortion]) {
    finderPattern = [aFinderPattern retain];
  }
  return self;
}

- (void) incrementCount {
  count++;
}

- (void) dealloc {
  [finderPattern release];
  [super dealloc];
}

@end

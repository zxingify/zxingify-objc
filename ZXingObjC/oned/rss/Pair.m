#import "RSSFinderPattern.h"
#import "Pair.h"

@implementation Pair

@synthesize count, finderPattern;

- (id) initWithValue:(int)aValue checksumPortion:(int)aChecksumPortion finderPattern:(RSSFinderPattern *)aFinderPattern {
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

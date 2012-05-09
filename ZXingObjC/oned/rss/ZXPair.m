#import "ZXRSSFinderPattern.h"
#import "ZXPair.h"

@interface ZXPair ()

@property (nonatomic, assign) int count;
@property (nonatomic, retain) ZXRSSFinderPattern * finderPattern;

@end

@implementation ZXPair

@synthesize count;
@synthesize finderPattern;

- (id)initWithValue:(int)aValue checksumPortion:(int)aChecksumPortion finderPattern:(ZXRSSFinderPattern *)aFinderPattern {
  if (self = [super initWithValue:aValue checksumPortion:aChecksumPortion]) {
    self.finderPattern = aFinderPattern;
  }

  return self;
}

- (void)dealloc {
  [finderPattern release];

  [super dealloc];
}


- (void)incrementCount {
  self.count++;
}

@end

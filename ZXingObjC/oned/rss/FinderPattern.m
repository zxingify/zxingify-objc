#import "FinderPattern.h"

@implementation FinderPattern

@synthesize value;
@synthesize startEnd;
@synthesize resultPoints;

- (id) initWithValue:(int)aValue startEnd:(NSArray *)aStartEnd start:(int)aStart end:(int)anEnd rowNumber:(int)aRowNumber {
  if (self = [super init]) {
    self.value = aValue;
    self.startEnd = aStartEnd;
    self.resultPoints = [NSArray arrayWithObjects:
                         [[[ResultPoint alloc] init:(float)aStart y:(float)aRowNumber] autorelease],
                         [[[ResultPoint alloc] init:(float)anEnd y:(float)aRowNumber] autorelease],
                         nil];
  }
  return self;
}

- (void) dealloc {
  [startEnd release];
  [resultPoints release];
  [super dealloc];
}

@end

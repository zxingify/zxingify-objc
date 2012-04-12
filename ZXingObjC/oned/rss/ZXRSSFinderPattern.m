#import "ZXRSSFinderPattern.h"

@implementation ZXRSSFinderPattern

@synthesize value;
@synthesize startEnd;
@synthesize resultPoints;

- (id) initWithValue:(int)aValue startEnd:(NSArray *)aStartEnd start:(int)aStart end:(int)anEnd rowNumber:(int)aRowNumber {
  if (self = [super init]) {
    self.value = aValue;
    self.startEnd = aStartEnd;
    self.resultPoints = [NSArray arrayWithObjects:
                         [[[ZXResultPoint alloc] initWithX:(float)aStart y:(float)aRowNumber] autorelease],
                         [[[ZXResultPoint alloc] initWithX:(float)anEnd y:(float)aRowNumber] autorelease],
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

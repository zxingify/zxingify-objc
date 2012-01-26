#import "FinderPatternInfo.h"

@implementation FinderPatternInfo

@synthesize bottomLeft;
@synthesize topLeft;
@synthesize topRight;

- (id) initWithPatternCenters:(NSArray *)patternCenters {
  if (self = [super init]) {
    bottomLeft = patternCenters[0];
    topLeft = patternCenters[1];
    topRight = patternCenters[2];
  }
  return self;
}

- (void) dealloc {
  [bottomLeft release];
  [topLeft release];
  [topRight release];
  [super dealloc];
}

@end

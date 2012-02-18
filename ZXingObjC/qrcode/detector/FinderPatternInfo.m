#import "FinderPatternInfo.h"
#import "QRCodeFinderPattern.h"

@implementation FinderPatternInfo

@synthesize bottomLeft;
@synthesize topLeft;
@synthesize topRight;

- (id) initWithPatternCenters:(NSArray *)patternCenters {
  if (self = [super init]) {
    bottomLeft = [patternCenters objectAtIndex:0];
    topLeft = [patternCenters objectAtIndex:1];
    topRight = [patternCenters objectAtIndex:2];
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

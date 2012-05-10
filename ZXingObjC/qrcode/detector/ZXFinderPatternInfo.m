#import "ZXFinderPatternInfo.h"
#import "ZXQRCodeFinderPattern.h"

@interface ZXFinderPatternInfo ()

@property (nonatomic, retain) ZXQRCodeFinderPattern * bottomLeft;
@property (nonatomic, retain) ZXQRCodeFinderPattern * topLeft;
@property (nonatomic, retain) ZXQRCodeFinderPattern * topRight;

@end

@implementation ZXFinderPatternInfo

@synthesize bottomLeft;
@synthesize topLeft;
@synthesize topRight;

- (id)initWithPatternCenters:(NSArray *)patternCenters {
  if (self = [super init]) {
    self.bottomLeft = [patternCenters objectAtIndex:0];
    self.topLeft = [patternCenters objectAtIndex:1];
    self.topRight = [patternCenters objectAtIndex:2];
  }

  return self;
}

- (void)dealloc {
  [bottomLeft release];
  [topLeft release];
  [topRight release];

  [super dealloc];
}

@end

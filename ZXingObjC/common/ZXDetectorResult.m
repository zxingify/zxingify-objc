#import "ZXBitMatrix.h"
#import "ZXDetectorResult.h"

@interface ZXDetectorResult ()

@property (nonatomic, retain) ZXBitMatrix * bits;
@property (nonatomic, retain) NSArray * points;

@end

@implementation ZXDetectorResult

@synthesize bits;
@synthesize points;

- (id) initWithBits:(ZXBitMatrix *)theBits points:(NSArray *)thePoints {
  self = [super init];
  if (self) {
    self.bits = theBits;
    self.points = thePoints;
  }

  return self;
}

- (void) dealloc {
  [bits release];
  [points release];

  [super dealloc];
}

@end

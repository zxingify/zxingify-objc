#import "ZXBitMatrix.h"
#import "ZXDetectorResult.h"

@implementation ZXDetectorResult

@synthesize bits;
@synthesize points;

- (id) initWithBits:(ZXBitMatrix *)theBits points:(NSArray *)thePoints {
  if (self = [super init]) {
    bits = [theBits retain];
    points = [thePoints retain];
  }
  return self;
}

- (void) dealloc {
  [bits release];
  [points release];
  [super dealloc];
}

@end

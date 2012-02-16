#import "BitMatrix.h"
#import "DetectorResult.h"

@implementation DetectorResult

@synthesize bits;
@synthesize points;

- (id) initWithBits:(BitMatrix *)theBits points:(NSArray *)thePoints {
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

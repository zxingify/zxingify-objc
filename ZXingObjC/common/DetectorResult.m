#import "DetectorResult.h"

@implementation DetectorResult

@synthesize bits;
@synthesize points;

- (id) initWithBits:(BitMatrix *)bits points:(NSArray *)points {
  if (self = [super init]) {
    bits = bits;
    points = points;
  }
  return self;
}

- (void) dealloc {
  [bits release];
  [points release];
  [super dealloc];
}

@end

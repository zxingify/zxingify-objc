#import "DecodedObject.h"

@implementation DecodedObject

@synthesize theNewPosition;

- (id) initWithNewPosition:(int)aNewPosition {
  if (self = [super init]) {
    theNewPosition = aNewPosition;
  }
  return self;
}

@end

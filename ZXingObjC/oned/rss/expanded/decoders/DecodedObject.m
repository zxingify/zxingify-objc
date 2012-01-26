#import "DecodedObject.h"

@implementation DecodedObject

- (id) initWithNewPosition:(int)aNewPosition {
  if (self = [super init]) {
    newPosition = aNewPosition;
  }
  return self;
}

- (int) getNewPosition {
  return newPosition;
}

@end

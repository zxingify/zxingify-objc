#import "DecodedObject.h"

@implementation DecodedObject

- (id) initWithNewPosition:(int)newPosition {
  if (self = [super init]) {
    newPosition = newPosition;
  }
  return self;
}

- (int) getNewPosition {
  return newPosition;
}

@end

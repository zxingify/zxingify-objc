#import "ZXDecodedObject.h"

@implementation ZXDecodedObject

@synthesize theNewPosition;

- (id) initWithNewPosition:(int)aNewPosition {
  if (self = [super init]) {
    theNewPosition = aNewPosition;
  }
  return self;
}

@end

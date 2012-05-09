#import "ZXDecodedObject.h"

@interface ZXDecodedObject ()

@property (nonatomic, assign) int theNewPosition;

@end

@implementation ZXDecodedObject

@synthesize theNewPosition;

- (id)initWithNewPosition:(int)aNewPosition {
  if (self = [super init]) {
    self.theNewPosition = aNewPosition;
  }

  return self;
}

@end

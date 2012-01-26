#import "NotFoundException.h"

static NotFoundException* instance = nil;

@implementation NotFoundException

+ (NotFoundException *)notFoundInstance {
  if (instance == nil) {
    instance = [[[NotFoundException alloc] init] autorelease];
  }

  return instance;
}

@end

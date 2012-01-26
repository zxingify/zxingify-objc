#import "NotFoundException.h"

NotFoundException * const instance = [[[NotFoundException alloc] init] autorelease];

@implementation NotFoundException

@synthesize notFoundInstance;

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

@end

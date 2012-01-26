#import "FormatException.h"

FormatException * const instance = [[[FormatException alloc] init] autorelease];

@implementation FormatException

@synthesize formatInstance;

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

@end

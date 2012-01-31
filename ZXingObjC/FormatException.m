#import "FormatException.h"

static FormatException* instance = nil;

@implementation FormatException

+ (FormatException *)formatInstance {
  if (instance == nil) {
    instance = [[[FormatException alloc] init] autorelease];
  }
  
  return instance;
}

@end

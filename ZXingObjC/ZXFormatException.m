#import "ZXFormatException.h"

static ZXFormatException* instance = nil;

@implementation ZXFormatException

+ (ZXFormatException *)formatInstance {
  if (instance == nil) {
    instance = [[[ZXFormatException alloc] init] autorelease];
  }
  
  return instance;
}

@end

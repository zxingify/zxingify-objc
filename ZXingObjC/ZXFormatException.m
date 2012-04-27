#import "ZXFormatException.h"

static ZXFormatException* instance = nil;

@implementation ZXFormatException

+ (ZXFormatException *)formatInstance {
  if (instance == nil) {
    instance = [[[ZXFormatException alloc] initWithName:@"FormatException" reason:@"Format Exception" userInfo:nil] autorelease];
  }
  
  return instance;
}

@end

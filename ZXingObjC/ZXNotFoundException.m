#import "ZXNotFoundException.h"

static ZXNotFoundException* instance = nil;

@implementation ZXNotFoundException

+ (ZXNotFoundException *)notFoundInstance {
  if (instance == nil) {
    instance = [[[ZXNotFoundException alloc] init] autorelease];
  }

  return instance;
}

@end

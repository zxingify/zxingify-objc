#import "ZXNotFoundException.h"

static ZXNotFoundException* instance = nil;

@implementation ZXNotFoundException

+ (ZXNotFoundException *)notFoundInstance {
  if (instance == nil) {
    instance = [[[ZXNotFoundException alloc] initWithName:@"NotFoundException" reason:@"Not Found" userInfo:nil] autorelease];
  }

  return instance;
}

@end

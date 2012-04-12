#import "ZXChecksumException.h"

static ZXChecksumException* instance = nil;

@implementation ZXChecksumException

+ (ZXChecksumException *)checksumInstance {
  if (instance == nil) {
    instance = [[[ZXChecksumException alloc] init] autorelease];
  }
  
  return instance;  
}

@end

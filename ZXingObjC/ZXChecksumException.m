#import "ZXChecksumException.h"

static ZXChecksumException* instance = nil;

@implementation ZXChecksumException

+ (ZXChecksumException *)checksumInstance {
  if (instance == nil) {
    instance = [[[ZXChecksumException alloc] initWithName:@"ChecksumException" reason:@"Checksum Exception" userInfo:nil] autorelease];
  }
  
  return instance;  
}

@end

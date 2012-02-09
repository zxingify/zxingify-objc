#import "ChecksumException.h"

static ChecksumException* instance = nil;

@implementation ChecksumException

+ (ChecksumException *)checksumInstance {
  if (instance == nil) {
    instance = [[[ChecksumException alloc] init] autorelease];
  }
  
  return instance;  
}

@end

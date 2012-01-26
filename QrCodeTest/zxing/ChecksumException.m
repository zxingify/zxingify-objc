#import "ChecksumException.h"

ChecksumException * const instance = [[[ChecksumException alloc] init] autorelease];

@implementation ChecksumException

@synthesize checksumInstance;

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

@end

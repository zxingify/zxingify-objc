#import "WriterException.h"

@implementation WriterException

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

- (id) initWithMessage:(NSString *)message {
  if (self = [super init:message]) {
  }
  return self;
}

@end

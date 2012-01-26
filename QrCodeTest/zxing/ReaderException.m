#import "ReaderException.h"

@implementation ReaderException

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

- (NSException *) fillInStackTrace {
  return nil;
}

@end

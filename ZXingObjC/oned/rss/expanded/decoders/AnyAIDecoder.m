#import "AnyAIDecoder.h"

int const HEADER_SIZE = 2 + 1 + 2;

@implementation AnyAIDecoder

- (id) initWithInformation:(BitArray *)information {
  if (self = [super init:information]) {
  }
  return self;
}

- (NSString *) parseInformation {
  NSMutableString * buf = [[[NSMutableString alloc] init] autorelease];
  return [generalDecoder decodeAllCodes:buf param1:HEADER_SIZE];
}

@end

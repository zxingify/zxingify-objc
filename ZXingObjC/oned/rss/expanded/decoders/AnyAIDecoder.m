#import "AnyAIDecoder.h"
#import "GeneralAppIdDecoder.h"

int const HEADER_SIZE = 2 + 1 + 2;

@implementation AnyAIDecoder

- (NSString *) parseInformation {
  NSMutableString * buf = [NSMutableString string];
  return [generalDecoder decodeAllCodes:buf initialPosition:HEADER_SIZE];
}

@end

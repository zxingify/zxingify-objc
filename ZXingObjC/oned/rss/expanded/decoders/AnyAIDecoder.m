#import "AnyAIDecoder.h"
#import "GeneralAppIdDecoder.h"

int const ANY_AI_HEADER_SIZE = 2 + 1 + 2;

@implementation AnyAIDecoder

- (NSString *) parseInformation {
  NSMutableString * buf = [NSMutableString string];
  return [generalDecoder decodeAllCodes:buf initialPosition:ANY_AI_HEADER_SIZE];
}

@end

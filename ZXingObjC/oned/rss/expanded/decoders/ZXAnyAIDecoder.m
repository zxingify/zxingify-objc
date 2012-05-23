#import "ZXAnyAIDecoder.h"
#import "ZXGeneralAppIdDecoder.h"

int const ANY_AI_HEADER_SIZE = 2 + 1 + 2;

@implementation ZXAnyAIDecoder

- (NSString *)parseInformationWithError:(NSError **)error {
  NSMutableString * buf = [NSMutableString string];
  return [self.generalDecoder decodeAllCodes:buf initialPosition:ANY_AI_HEADER_SIZE error:error];
}

@end

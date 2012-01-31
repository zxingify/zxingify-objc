#import "Result.h"
#import "WifiResultParser.h"
#import "WifiParsedResult.h"

@implementation WifiResultParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (WifiParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil || ![rawText hasPrefix:@"WIFI:"]) {
    return nil;
  }
  BOOL trim = NO;
  NSString * ssid = [self matchSinglePrefixedField:@"S:" param1:rawText param2:';' param3:trim];
  NSString * pass = [self matchSinglePrefixedField:@"P:" param1:rawText param2:';' param3:trim];
  NSString * type = [self matchSinglePrefixedField:@"T:" param1:rawText param2:';' param3:trim];
  return [[[WifiParsedResult alloc] init:type param1:ssid param2:pass] autorelease];
}

@end

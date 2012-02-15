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
  NSString * ssid = [self matchSinglePrefixedField:@"S:" rawText:rawText endChar:';' trim:trim];
  NSString * pass = [self matchSinglePrefixedField:@"P:" rawText:rawText endChar:';' trim:trim];
  NSString * type = [self matchSinglePrefixedField:@"T:" rawText:rawText endChar:';' trim:trim];
  return [[[WifiParsedResult alloc] initWithNetworkEncryption:type ssid:ssid password:pass] autorelease];
}

@end

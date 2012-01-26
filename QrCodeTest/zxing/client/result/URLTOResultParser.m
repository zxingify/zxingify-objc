#import "URLTOResultParser.h"

@implementation URLTOResultParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (URIParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil || (![rawText hasPrefix:@"urlto:"] && ![rawText hasPrefix:@"URLTO:"])) {
    return nil;
  }
  int titleEnd = [rawText rangeOfString:':' param1:6];
  if (titleEnd < 0) {
    return nil;
  }
  NSString * title = titleEnd <= 6 ? nil : [rawText substringFromIndex:6 param1:titleEnd];
  NSString * uri = [rawText substringFromIndex:titleEnd + 1];
  return [[[URIParsedResult alloc] init:uri param1:title] autorelease];
}

@end

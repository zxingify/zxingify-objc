#import "Result.h"
#import "URIParsedResult.h"
#import "URLTOResultParser.h"

@implementation URLTOResultParser

+ (URIParsedResult *) parse:(Result *)result {
  NSString * rawText = result.text;
  if (rawText == nil || (![rawText hasPrefix:@"urlto:"] && ![rawText hasPrefix:@"URLTO:"])) {
    return nil;
  }
  int titleEnd = [rawText rangeOfString:@":" options:NSLiteralSearch range:NSMakeRange(6, [rawText length] - 6)].location;
  if (titleEnd < 0) {
    return nil;
  }
  NSString * title = titleEnd <= 6 ? nil : [rawText substringWithRange:NSMakeRange(6, [rawText length] - titleEnd)];
  NSString * uri = [rawText substringFromIndex:titleEnd + 1];
  return [[[URIParsedResult alloc] initWithUri:uri title:title] autorelease];
}

@end

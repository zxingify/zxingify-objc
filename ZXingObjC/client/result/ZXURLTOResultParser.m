#import "ZXResult.h"
#import "ZXURIParsedResult.h"
#import "ZXURLTOResultParser.h"

@implementation ZXURLTOResultParser

+ (ZXURIParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = result.text;
  if (rawText == nil || (![rawText hasPrefix:@"urlto:"] && ![rawText hasPrefix:@"URLTO:"])) {
    return nil;
  }
  int titleEnd = [rawText rangeOfString:@":" options:NSLiteralSearch range:NSMakeRange(6, [rawText length] - 6)].location;
  if (titleEnd == NSNotFound) {
    return nil;
  }
  NSString * title = titleEnd <= 6 ? nil : [rawText substringWithRange:NSMakeRange(6, titleEnd - 6)];
  NSString * uri = [rawText substringFromIndex:titleEnd + 1];
  return [[[ZXURIParsedResult alloc] initWithUri:uri title:title] autorelease];
}

@end

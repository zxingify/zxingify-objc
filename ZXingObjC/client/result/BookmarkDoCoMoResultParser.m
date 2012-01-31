#import "BookmarkDoCoMoResultParser.h"
#import "URIParsedResult.h"
#import "Result.h"

@implementation BookmarkDoCoMoResultParser

+ (URIParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil || ![rawText hasPrefix:@"MEBKM:"]) {
    return nil;
  }
  NSString * title = [self matchSingleDoCoMoPrefixedField:@"TITLE:" param1:rawText param2:YES];
  NSArray * rawUri = [self matchDoCoMoPrefixedField:@"URL:" param1:rawText param2:YES];
  if (rawUri == nil) {
    return nil;
  }
  NSString * uri = rawUri[0];
  if (![URIResultParser isBasicallyValidURI:uri]) {
    return nil;
  }
  return [[[URIParsedResult alloc] init:uri param1:title] autorelease];
}

@end

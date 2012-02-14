#import "BookmarkDoCoMoResultParser.h"
#import "Result.h"
#import "URIParsedResult.h"
#import "URIResultParser.h"

@implementation BookmarkDoCoMoResultParser

+ (URIParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil || ![rawText hasPrefix:@"MEBKM:"]) {
    return nil;
  }
  NSString * title = [self matchSingleDoCoMoPrefixedField:@"TITLE:" rawText:rawText trim:YES];
  NSArray * rawUri = [self matchDoCoMoPrefixedField:@"URL:" rawText:rawText trim:YES];
  if (rawUri == nil) {
    return nil;
  }
  NSString * uri = [rawUri objectAtIndex:0];
  if (![URIResultParser isBasicallyValidURI:uri]) {
    return nil;
  }
  return [[[URIParsedResult alloc] initWithUri:uri title:title] autorelease];
}

@end

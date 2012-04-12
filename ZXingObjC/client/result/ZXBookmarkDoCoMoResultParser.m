#import "ZXBookmarkDoCoMoResultParser.h"
#import "ZXResult.h"
#import "ZXURIParsedResult.h"
#import "ZXURIResultParser.h"

@implementation ZXBookmarkDoCoMoResultParser

+ (ZXURIParsedResult *) parse:(ZXResult *)result {
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
  if (![ZXURIResultParser isBasicallyValidURI:uri]) {
    return nil;
  }
  return [[[ZXURIParsedResult alloc] initWithUri:uri title:title] autorelease];
}

@end

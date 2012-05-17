#import "ZXURIResultParser.h"
#import "ZXResult.h"
#import "ZXURIParsedResult.h"

@implementation ZXURIResultParser

+ (ZXURIParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = [result text];
  if (rawText != nil && [rawText hasPrefix:@"URL:"]) {
    rawText = [rawText substringFromIndex:4];
  }
  if (rawText != nil) {
    rawText = [rawText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  }
  if (![self isBasicallyValidURI:rawText]) {
    return nil;
  }
  return [[[ZXURIParsedResult alloc] initWithUri:rawText title:nil] autorelease];
}


/**
 * Determines whether a string is not obviously not a URI. This implements crude checks; this class does not
 * intend to strictly check URIs as its only function is to represent what is in a barcode, but, it does
 * need to know when a string is obviously not a URI.
 */
+ (BOOL)isBasicallyValidURI:(NSString *)uri {
  if (uri == nil || [uri rangeOfString:@" "].location != NSNotFound || [uri rangeOfString:@"\n"].location != NSNotFound) {
    return NO;
  }
  int period = [uri rangeOfString:@"."].location;
  if (period != NSNotFound && period >= [uri length] - 2) {
    return NO;
  }
  int colon = [uri rangeOfString:@":"].location;
  if (period == NSNotFound && colon == NSNotFound) {
    return NO;
  }
  if (colon != NSNotFound) {
    if (period == NSNotFound || period > colon) {
      for (int i = 0; i < colon; i++) {
        unichar c = [uri characterAtIndex:i];
        if ((c < 'a' || c > 'z') && (c < 'A' || c > 'Z')) {
          return NO;
        }
      }
    } else {
      if (colon >= [uri length] - 2) {
        return NO;
      }

      for (int i = colon + 1; i < colon + 3; i++) {
        unichar c = [uri characterAtIndex:i];
        if (c < '0' || c > '9') {
          return NO;
        }
      }
    }
  }
  return YES;
}

@end

#import "URIResultParser.h"

@implementation URIResultParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (URIParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText != nil && [rawText hasPrefix:@"URL:"]) {
    rawText = [rawText substringFromIndex:4];
  }
  if (rawText != nil) {
    rawText = [rawText stringByTrimmingCharactersInSet];
  }
  if (![self isBasicallyValidURI:rawText]) {
    return nil;
  }
  return [[[URIParsedResult alloc] init:rawText param1:nil] autorelease];
}


/**
 * Determines whether a string is not obviously not a URI. This implements crude checks; this class does not
 * intend to strictly check URIs as its only function is to represent what is in a barcode, but, it does
 * need to know when a string is obviously not a URI.
 */
+ (BOOL) isBasicallyValidURI:(NSString *)uri {
  if (uri == nil || [uri rangeOfString:' '] >= 0 || [uri rangeOfString:'\n'] >= 0) {
    return NO;
  }
  int period = [uri rangeOfString:'.'];
  if (period >= [uri length] - 2) {
    return NO;
  }
  int colon = [uri rangeOfString:':'];
  if (period < 0 && colon < 0) {
    return NO;
  }
  if (colon >= 0) {
    if (period < 0 || period > colon) {

      for (int i = 0; i < colon; i++) {
        unichar c = [uri characterAtIndex:i];
        if ((c < 'a' || c > 'z') && (c < 'A' || c > 'Z')) {
          return NO;
        }
      }

    }
     else {
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

#import "ZXURIResultParser.h"
#import "ZXResult.h"
#import "ZXURIParsedResult.h"

@implementation ZXURIResultParser

+ (ZXURIParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = [result text];
  // We specifically handle the odd "URL" scheme here for simplicity
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
  if (uri == nil) {
    return NO;
  }
  int period = -1;
  int colon = -1;
  int length = [uri length];
  for (int i = length - 1; i >= 0; i--) {
    char c = [uri characterAtIndex:i];
    if (c <= ' ') { // covers space, newline, and more
      return NO;
    } else if (c == '.') {
      period = i;
    } else if (c == ':') {
      colon = i;
    }
  }
  // Look for period in a domain but followed by at least a two-char TLD
  // Forget strings that don't have a valid-looking protocol
  if (period >= (int)[uri length] - 2 || (period < 0 && colon < 0)) {
    return NO;
  }
  if (colon >= 0) {
    if (period < 0 || period > colon) {
      // colon ends the protocol
      for (int i = 0; i < colon; i++) {
        unichar c = [uri characterAtIndex:i];
        if ((c < 'a' || c > 'z') && (c < 'A' || c > 'Z')) {
          return NO;
        }
      }
    } else {
      // colon starts the port; crudely look for at least two numbers
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

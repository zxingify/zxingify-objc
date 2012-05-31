/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXURIResultParser.h"
#import "ZXResult.h"
#import "ZXURIParsedResult.h"

@implementation ZXURIResultParser

- (ZXParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = [result text];
  // We specifically handle the odd "URL" scheme here for simplicity
  if ([rawText hasPrefix:@"URL:"]) {
    rawText = [rawText substringFromIndex:4];
  }
  rawText = [rawText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  if (![[self class] isBasicallyValidURI:rawText]) {
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
  if (period >= (int)[uri length] - 2 || (period <= 0 && colon <= 0)) {
    return NO;
  }
  if (colon >= 0) {
    if (period < 0 || period > colon) {
      if (![self isSubstringOfAlphaNumeric:uri offset:0 length:colon]) {
        return NO;
      }
    } else {
      // colon starts the port; crudely look for at least two numbers
      if (colon >= [uri length] - 2) {
        return NO;
      }
      if (![self isSubstringOfDigits:uri offset:colon + 1 length:2]) {
        return NO;
      }
    }
  }
  return YES;
}

@end

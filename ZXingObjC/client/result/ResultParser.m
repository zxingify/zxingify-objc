#import "ResultParser.h"

@implementation ResultParser

+ (ParsedResult *) parseResult:(Result *)theResult {
  ParsedResult * result;
  if ((result = [BookmarkDoCoMoResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [AddressBookDoCoMoResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [EmailDoCoMoResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [AddressBookAUResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [VCardResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [BizcardResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [VEventResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [EmailAddressResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [SMTPResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [TelResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [SMSMMSResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [SMSTOMMSTOResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [GeoResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [WifiResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [URLTOResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [URIResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [ISBNResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [ProductResultParser parse:theResult]) != nil) {
    return result;
  }
   else if ((result = [ExpandedProductResultParser parse:theResult]) != nil) {
    return result;
  }
  return [[[TextParsedResult alloc] init:[theResult text] param1:nil] autorelease];
}

+ (void) maybeAppend:(NSString *)value result:(NSMutableString *)result {
  if (value != nil) {
    [result append:'\n'];
    [result append:value];
  }
}

+ (void) maybeAppend:(NSArray *)value result:(NSMutableString *)result {
  if (value != nil) {

    for (int i = 0; i < value.length; i++) {
      [result append:'\n'];
      [result append:value[i]];
    }

  }
}

+ (NSArray *) maybeWrap:(NSString *)value {
  return value == nil ? nil : [NSArray arrayWithObjects:value, nil];
}

+ (NSString *) unescapeBackslash:(NSString *)escaped {
  if (escaped != nil) {
    int backslash = [escaped rangeOfString:(int)'\\'];
    if (backslash >= 0) {
      int max = [escaped length];
      NSMutableString * unescaped = [[[NSMutableString alloc] init:max - 1] autorelease];
      [unescaped append:[escaped toCharArray] param1:0 param2:backslash];
      BOOL nextIsEscaped = NO;

      for (int i = backslash; i < max; i++) {
        unichar c = [escaped characterAtIndex:i];
        if (nextIsEscaped || c != '\\') {
          [unescaped append:c];
          nextIsEscaped = NO;
        }
         else {
          nextIsEscaped = YES;
        }
      }

      return [unescaped description];
    }
  }
  return escaped;
}

+ (NSString *) urlDecode:(NSString *)escaped {
  if (escaped == nil) {
    return nil;
  }
  NSArray * escapedArray = [escaped toCharArray];
  int first = [self findFirstEscape:escapedArray];
  if (first < 0) {
    return escaped;
  }
  int max = escapedArray.length;
  NSMutableString * unescaped = [[[NSMutableString alloc] init:max - 2] autorelease];
  [unescaped append:escapedArray param1:0 param2:first];

  for (int i = first; i < max; i++) {
    unichar c = escapedArray[i];

    switch (c) {
    case '+':
      [unescaped append:' '];
      break;
    case '%':
      if (i >= max - 2) {
        [unescaped append:'%'];
      }
       else {
        int firstDigitValue = [self parseHexDigit:escapedArray[++i]];
        int secondDigitValue = [self parseHexDigit:escapedArray[++i]];
        if (firstDigitValue < 0 || secondDigitValue < 0) {
          [unescaped append:'%'];
          [unescaped append:escapedArray[i - 1]];
          [unescaped append:escapedArray[i]];
        }
        [unescaped append:(unichar)((firstDigitValue << 4) + secondDigitValue)];
      }
      break;
    default:
      [unescaped append:c];
      break;
    }
  }

  return [unescaped description];
}

+ (int) findFirstEscape:(NSArray *)escapedArray {
  int max = escapedArray.length;

  for (int i = 0; i < max; i++) {
    unichar c = escapedArray[i];
    if (c == '+' || c == '%') {
      return i;
    }
  }

  return -1;
}

+ (int) parseHexDigit:(unichar)c {
  if (c >= 'a') {
    if (c <= 'f') {
      return 10 + (c - 'a');
    }
  }
   else if (c >= 'A') {
    if (c <= 'F') {
      return 10 + (c - 'A');
    }
  }
   else if (c >= '0') {
    if (c <= '9') {
      return c - '0';
    }
  }
  return -1;
}

+ (BOOL) isStringOfDigits:(NSString *)value length:(int)length {
  if (value == nil) {
    return NO;
  }
  int stringLength = [value length];
  if (length != stringLength) {
    return NO;
  }

  for (int i = 0; i < length; i++) {
    unichar c = [value characterAtIndex:i];
    if (c < '0' || c > '9') {
      return NO;
    }
  }

  return YES;
}

+ (BOOL) isSubstringOfDigits:(NSString *)value offset:(int)offset length:(int)length {
  if (value == nil) {
    return NO;
  }
  int stringLength = [value length];
  int max = offset + length;
  if (stringLength < max) {
    return NO;
  }

  for (int i = offset; i < max; i++) {
    unichar c = [value characterAtIndex:i];
    if (c < '0' || c > '9') {
      return NO;
    }
  }

  return YES;
}

+ (NSMutableDictionary *) parseNameValuePairs:(NSString *)uri {
  int paramStart = [uri rangeOfString:'?'];
  if (paramStart < 0) {
    return nil;
  }
  NSMutableDictionary * result = [[[NSMutableDictionary alloc] init:3] autorelease];
  paramStart++;
  int paramEnd;

  while ((paramEnd = [uri rangeOfString:'&' param1:paramStart]) >= 0) {
    [self appendKeyValue:uri paramStart:paramStart paramEnd:paramEnd result:result];
    paramStart = paramEnd + 1;
  }

  [self appendKeyValue:uri paramStart:paramStart paramEnd:[uri length] result:result];
  return result;
}

+ (void) appendKeyValue:(NSString *)uri paramStart:(int)paramStart paramEnd:(int)paramEnd result:(NSMutableDictionary *)result {
  int separator = [uri rangeOfString:'=' param1:paramStart];
  if (separator >= 0) {
    NSString * key = [uri substringFromIndex:paramStart param1:separator];
    NSString * value = [uri substringFromIndex:separator + 1 param1:paramEnd];
    value = [self urlDecode:value];
    [result setObject:key param1:value];
  }
}

+ (NSArray *) matchPrefixedField:(NSString *)prefix rawText:(NSString *)rawText endChar:(unichar)endChar trim:(BOOL)trim {
  NSMutableArray * matches = nil;
  int i = 0;
  int max = [rawText length];

  while (i < max) {
    i = [rawText rangeOfString:prefix param1:i];
    if (i < 0) {
      break;
    }
    i += [prefix length];
    int start = i;
    BOOL done = NO;

    while (!done) {
      i = [rawText rangeOfString:(int)endChar param1:i];
      if (i < 0) {
        i = [rawText length];
        done = YES;
      }
       else if ([rawText characterAtIndex:i - 1] == '\\') {
        i++;
      }
       else {
        if (matches == nil) {
          matches = [[[NSMutableArray alloc] init:3] autorelease];
        }
        NSString * element = [self unescapeBackslash:[rawText substringFromIndex:start param1:i]];
        if (trim) {
          element = [element stringByTrimmingCharactersInSet];
        }
        [matches addObject:element];
        i++;
        done = YES;
      }
    }

  }

  if (matches == nil || [matches empty]) {
    return nil;
  }
  return [self toStringArray:matches];
}

+ (NSString *) matchSinglePrefixedField:(NSString *)prefix rawText:(NSString *)rawText endChar:(unichar)endChar trim:(BOOL)trim {
  NSArray * matches = [self matchPrefixedField:prefix rawText:rawText endChar:endChar trim:trim];
  return matches == nil ? nil : matches[0];
}

+ (NSArray *) toStringArray:(NSMutableArray *)strings {
  int size = [strings count];
  NSArray * result = [NSArray array];

  for (int j = 0; j < size; j++) {
    result[j] = (NSString *)[strings objectAtIndex:j];
  }

  return result;
}

@end

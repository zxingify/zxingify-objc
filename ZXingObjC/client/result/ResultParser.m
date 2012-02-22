#import "AddressBookAUResultParser.h"
#import "AddressBookDoCoMoResultParser.h"
#import "AddressBookParsedResult.h"
#import "BizcardResultParser.h"
#import "BookmarkDoCoMoResultParser.h"
#import "CalendarParsedResult.h"
#import "EmailAddressParsedResult.h"
#import "EmailAddressResultParser.h"
#import "EmailDoCoMoResultParser.h"
#import "ExpandedProductParsedResult.h"
#import "ExpandedProductResultParser.h"
#import "GeoParsedResult.h"
#import "GeoResultParser.h"
#import "ISBNParsedResult.h"
#import "ISBNResultParser.h"
#import "ParsedResult.h"
#import "ProductParsedResult.h"
#import "ProductResultParser.h"
#import "Result.h"
#import "ResultParser.h"
#import "SMSMMSResultParser.h"
#import "SMSParsedResult.h"
#import "SMSTOMMSTOResultParser.h"
#import "SMTPResultParser.h"
#import "TelParsedResult.h"
#import "TelResultParser.h"
#import "TextParsedResult.h"
#import "URIParsedResult.h"
#import "URIResultParser.h"
#import "URLTOResultParser.h"
#import "VCardResultParser.h"
#import "VEventResultParser.h"
#import "WifiParsedResult.h"
#import "WifiResultParser.h"

@interface ResultParser ()

+ (void) appendKeyValue:(NSString *)uri paramStart:(int)paramStart paramEnd:(int)paramEnd result:(NSMutableDictionary *)result;
+ (int) findFirstEscape:(NSString *)escaped;
+ (int) parseHexDigit:(unichar)c;

@end

@implementation ResultParser

+ (ParsedResult *) parseResult:(Result *)theResult {
  ParsedResult * result;
  if ((result = [BookmarkDoCoMoResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [AddressBookDoCoMoResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [EmailDoCoMoResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [AddressBookAUResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [VCardResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [BizcardResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [VEventResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [EmailAddressResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [SMTPResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [TelResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [SMSMMSResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [SMSTOMMSTOResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [GeoResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [WifiResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [URLTOResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [URIResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ISBNResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ProductResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ExpandedProductResultParser parse:theResult]) != nil) {
    return result;
  }
  return [[[TextParsedResult alloc] initWithText:[theResult text] language:nil] autorelease];
}

+ (void) maybeAppend:(NSString *)value result:(NSMutableString *)result {
  if (value != nil) {
    [result appendFormat:@"\n%@", value];
  }
}

+ (void) maybeAppendArray:(NSArray *)value result:(NSMutableString *)result {
  if (value != nil) {
    for (id i in value) {
      [result appendFormat:@"\n%@", i];
    }
  }
}

+ (NSArray *) maybeWrap:(NSString *)value {
  return value == nil ? nil : [NSArray arrayWithObjects:value, nil];
}

+ (NSString *) unescapeBackslash:(NSString *)escaped {
  if (escaped != nil) {
    int backslash = [escaped rangeOfString:@"\\"].location;
    if (backslash >= 0) {
      int max = [escaped length];
      NSMutableString * unescaped = [NSMutableString stringWithCapacity:max - 1];
      [unescaped appendString:[escaped substringToIndex:backslash]];
      BOOL nextIsEscaped = NO;
      for (int i = backslash; i < max; i++) {
        unichar c = [escaped characterAtIndex:i];
        if (nextIsEscaped || c != '\\') {
          [unescaped appendFormat:@"%C", c];
          nextIsEscaped = NO;
        } else {
          nextIsEscaped = YES;
        }
      }
      return unescaped;
    }
  }
  return escaped;
}

+ (NSString *) urlDecode:(NSString *)escaped {
  if (escaped == nil) {
    return nil;
  }

  int first = [self findFirstEscape:escaped];
  if (first < 0) {
    return escaped;
  }

  int max = [escaped length];
  NSMutableString * unescaped = [NSMutableString stringWithCapacity:max - 2];
  [unescaped appendString:[escaped substringToIndex:first]];

  for (int i = first; i < max; i++) {
    unichar c = [escaped characterAtIndex:i];
    switch (c) {
    case '+':
      [unescaped appendString:@" "];
      break;
    case '%':
      if (i >= max - 2) {
        [unescaped appendString:@"%"];
      } else {
        int firstDigitValue = [self parseHexDigit:[escaped characterAtIndex:++i]];
        int secondDigitValue = [self parseHexDigit:[escaped characterAtIndex:++i]];
        if (firstDigitValue < 0 || secondDigitValue < 0) {
          [unescaped appendFormat:@"%%%C%C", [escaped characterAtIndex:i - 1], [escaped characterAtIndex:i]];
        }
        [unescaped appendFormat:@"%C", (unichar)((firstDigitValue << 4) + secondDigitValue)];
      }
      break;
    default:
      [unescaped appendFormat:@"%C", c];
      break;
    }
  }

  return unescaped;
}

+ (int) findFirstEscape:(NSString *)escaped {
  int max = [escaped length];
  for (int i = 0; i < max; i++) {
    unichar c = [escaped characterAtIndex:i];
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

+ (BOOL) isStringOfDigits:(NSString *)value length:(unsigned int)length {
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

+ (BOOL) isSubstringOfDigits:(NSString *)value offset:(int)offset length:(unsigned int)length {
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
  int paramStart = [uri rangeOfString:@"?"].location;
  if (paramStart < 0) {
    return nil;
  }
  NSMutableDictionary * result = [NSMutableDictionary dictionaryWithCapacity:3];
  paramStart++;
  int paramEnd;
  while ((paramEnd = [uri rangeOfString:@"&" options:NSLiteralSearch range:NSMakeRange(paramStart, [uri length] - paramStart)].location) >= 0) {
    [self appendKeyValue:uri paramStart:paramStart paramEnd:paramEnd result:result];
    paramStart = paramEnd + 1;
  }

  [self appendKeyValue:uri paramStart:paramStart paramEnd:[uri length] result:result];
  return result;
}

+ (void) appendKeyValue:(NSString *)uri paramStart:(int)paramStart paramEnd:(int)paramEnd result:(NSMutableDictionary *)result {
  int separator = [uri rangeOfString:@"=" options:NSLiteralSearch range:NSMakeRange(paramStart, [uri length] - paramStart)].location;
  if (separator >= 0) {
    NSString * key = [uri substringWithRange:NSMakeRange(paramStart, [uri length] - separator)];
    NSString * value = [uri substringWithRange:NSMakeRange(separator + 1, [uri length] - paramEnd)];
    value = [self urlDecode:value];
    [result setObject:value forKey:key];
  }
}

+ (NSArray *) matchPrefixedField:(NSString *)prefix rawText:(NSString *)rawText endChar:(unichar)endChar trim:(BOOL)trim {
  NSMutableArray * matches = nil;
  int i = 0;
  int max = [rawText length];

  while (i < max) {
    i = [rawText rangeOfString:prefix options:NSLiteralSearch range:NSMakeRange(i, [rawText length] - i)].location;
    if (i < 0) {
      break;
    }
    i += [prefix length];
    int start = i;
    BOOL done = NO;
    while (!done) {
      i = [rawText rangeOfString:[NSString stringWithFormat:@"%C", endChar] options:NSLiteralSearch range:NSMakeRange(i, [rawText length] - i)].location;
      if (i < 0) {
        i = [rawText length];
        done = YES;
      } else if ([rawText characterAtIndex:i - 1] == '\\') {
        i++;
      } else {
        if (matches == nil) {
          matches = [NSMutableArray arrayWithCapacity:3];
        }
        NSString * element = [self unescapeBackslash:[rawText substringWithRange:NSMakeRange(start, [rawText length] - i)]];
        if (trim) {
          element = [element stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        [matches addObject:element];
        i++;
        done = YES;
      }
    }
  }
  if (matches == nil || [matches count] == 0) {
    return nil;
  }
  return matches;
}

+ (NSString *) matchSinglePrefixedField:(NSString *)prefix rawText:(NSString *)rawText endChar:(unichar)endChar trim:(BOOL)trim {
  NSArray * matches = [self matchPrefixedField:prefix rawText:rawText endChar:endChar trim:trim];
  return matches == nil ? nil : [matches objectAtIndex:0];
}

@end

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

#import "ZXAddressBookAUResultParser.h"
#import "ZXAddressBookDoCoMoResultParser.h"
#import "ZXAddressBookParsedResult.h"
#import "ZXBizcardResultParser.h"
#import "ZXBookmarkDoCoMoResultParser.h"
#import "ZXCalendarParsedResult.h"
#import "ZXEmailAddressParsedResult.h"
#import "ZXEmailAddressResultParser.h"
#import "ZXEmailDoCoMoResultParser.h"
#import "ZXExpandedProductParsedResult.h"
#import "ZXExpandedProductResultParser.h"
#import "ZXGeoParsedResult.h"
#import "ZXGeoResultParser.h"
#import "ZXISBNParsedResult.h"
#import "ZXISBNResultParser.h"
#import "ZXParsedResult.h"
#import "ZXProductParsedResult.h"
#import "ZXProductResultParser.h"
#import "ZXResult.h"
#import "ZXResultParser.h"
#import "ZXSMSMMSResultParser.h"
#import "ZXSMSParsedResult.h"
#import "ZXSMSTOMMSTOResultParser.h"
#import "ZXSMTPResultParser.h"
#import "ZXTelParsedResult.h"
#import "ZXTelResultParser.h"
#import "ZXTextParsedResult.h"
#import "ZXURIParsedResult.h"
#import "ZXURIResultParser.h"
#import "ZXURLTOResultParser.h"
#import "ZXVCardResultParser.h"
#import "ZXVEventResultParser.h"
#import "ZXWifiParsedResult.h"
#import "ZXWifiResultParser.h"

@interface ZXResultParser ()

+ (void)appendKeyValue:(NSString *)uri paramStart:(int)paramStart paramEnd:(int)paramEnd result:(NSMutableDictionary *)result;
+ (int)findFirstEscape:(NSString *)escaped;
+ (int)parseHexDigit:(unichar)c;

@end

@implementation ZXResultParser

+ (ZXParsedResult *) parseResult:(ZXResult *)theResult {
  ZXParsedResult * result = nil;
  if ((result = [ZXBookmarkDoCoMoResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXAddressBookDoCoMoResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXEmailDoCoMoResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXAddressBookAUResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXVCardResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXBizcardResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXVEventResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXEmailAddressResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXSMTPResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXTelResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXSMSMMSResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXSMSTOMMSTOResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXGeoResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXWifiResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXURLTOResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXURIResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXISBNResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXProductResultParser parse:theResult]) != nil) {
    return result;
  } else if ((result = [ZXExpandedProductResultParser parse:theResult]) != nil) {
    return result;
  }
  return [[[ZXTextParsedResult alloc] initWithText:[theResult text] language:nil] autorelease];
}

+ (void)maybeAppend:(NSString *)value result:(NSMutableString *)result {
  if (value != nil) {
    [result appendFormat:@"\n%@", value];
  }
}

+ (void)maybeAppendArray:(NSArray *)value result:(NSMutableString *)result {
  if (value != nil) {
    for (id i in value) {
      [result appendFormat:@"\n%@", i];
    }
  }
}

+ (NSArray *)maybeWrap:(NSString *)value {
  return value == nil ? nil : [NSArray arrayWithObjects:value, nil];
}

+ (NSString *)unescapeBackslash:(NSString *)escaped {
  if (escaped != nil) {
    int backslash = [escaped rangeOfString:@"\\"].location;
    if (backslash != NSNotFound) {
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

+ (NSString *)urlDecode:(NSString *)escaped {
  if (escaped == nil) {
    return nil;
  }

  int first = [self findFirstEscape:escaped];
  if (first == NSNotFound) {
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

+ (int)findFirstEscape:(NSString *)escaped {
  int max = [escaped length];
  for (int i = 0; i < max; i++) {
    unichar c = [escaped characterAtIndex:i];
    if (c == '+' || c == '%') {
      return i;
    }
  }

  return NSNotFound;
}

+ (int)parseHexDigit:(unichar)c {
  if (c >= 'a') {
    if (c <= 'f') {
      return 10 + (c - 'a');
    }
  } else if (c >= 'A') {
    if (c <= 'F') {
      return 10 + (c - 'A');
    }
  } else if (c >= '0') {
    if (c <= '9') {
      return c - '0';
    }
  }

  return NSNotFound;
}

+ (BOOL)isStringOfDigits:(NSString *)value length:(unsigned int)length {
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

+ (BOOL)isSubstringOfDigits:(NSString *)value offset:(int)offset length:(unsigned int)length {
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

+ (NSMutableDictionary *)parseNameValuePairs:(NSString *)uri {
  int paramStart = [uri rangeOfString:@"?"].location;
  if (paramStart == NSNotFound) {
    return nil;
  }
  NSMutableDictionary * result = [NSMutableDictionary dictionaryWithCapacity:3];
  paramStart++;
  int paramEnd;
  while ((paramEnd = [uri rangeOfString:@"&" options:NSLiteralSearch range:NSMakeRange(paramStart, [uri length] - paramStart)].location) != NSNotFound) {
    [self appendKeyValue:uri paramStart:paramStart paramEnd:paramEnd result:result];
    paramStart = paramEnd + 1;
  }

  [self appendKeyValue:uri paramStart:paramStart paramEnd:[uri length] result:result];
  return result;
}

+ (void)appendKeyValue:(NSString *)uri paramStart:(int)paramStart paramEnd:(int)paramEnd result:(NSMutableDictionary *)result {
  int separator = [uri rangeOfString:@"=" options:NSLiteralSearch range:NSMakeRange(paramStart, [uri length] - paramStart)].location;
  if (separator != NSNotFound) {
    NSString * key = [uri substringWithRange:NSMakeRange(paramStart, separator - paramStart)];
    NSString * value = [uri substringWithRange:NSMakeRange(separator + 1, paramEnd - separator - 1)];
    value = [self urlDecode:value];
    [result setObject:value forKey:key];
  }
}

+ (NSArray *)matchPrefixedField:(NSString *)prefix rawText:(NSString *)rawText endChar:(unichar)endChar trim:(BOOL)trim {
  NSMutableArray * matches = nil;
  int i = 0;
  int max = [rawText length];

  while (i < max) {
    i = [rawText rangeOfString:prefix options:NSLiteralSearch range:NSMakeRange(i, [rawText length] - i - 1)].location;
    if (i == NSNotFound) {
      break;
    }
    i += [prefix length];
    int start = i;
    BOOL done = NO;
    while (!done) {
      i = [rawText rangeOfString:[NSString stringWithFormat:@"%C", endChar] options:NSLiteralSearch range:NSMakeRange(i, [rawText length] - i)].location;
      if (i == NSNotFound) {
        i = [rawText length];
        done = YES;
      } else if ([rawText characterAtIndex:i - 1] == '\\') {
        i++;
      } else {
        if (matches == nil) {
          matches = [NSMutableArray arrayWithCapacity:3];
        }
        NSString * element = [self unescapeBackslash:[rawText substringWithRange:NSMakeRange(start, i - start)]];
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

+ (NSString *)matchSinglePrefixedField:(NSString *)prefix rawText:(NSString *)rawText endChar:(unichar)endChar trim:(BOOL)trim {
  NSArray * matches = [self matchPrefixedField:prefix rawText:rawText endChar:endChar trim:trim];
  return matches == nil ? nil : [matches objectAtIndex:0];
}

@end

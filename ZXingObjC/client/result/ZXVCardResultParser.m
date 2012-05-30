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

#import "ZXAddressBookParsedResult.h"
#import "ZXResult.h"
#import "ZXVCardResultParser.h"

@interface ZXVCardResultParser ()

+ (NSString *)decodeQuotedPrintable:(NSString *)value charset:(NSString *)charset;
+ (NSString *)formatAddress:(NSString *)address;
+ (void)formatNames:(NSMutableArray *)names;
+ (BOOL)isLikeVCardDate:(NSString *)value;
+ (void)maybeAppendFragment:(NSMutableData *)fragmentBuffer charset:(NSString *)charset result:(NSMutableString *)result;
+ (void)maybeAppendComponent:(NSArray *)components i:(int)i newName:(NSMutableString *)newName;
+ (NSMutableArray *)matchVCardPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim;
+ (NSString *)stripContinuationCRLF:(NSString *)value;
+ (int)toHexValue:(unichar)c;
+ (NSString*)toPrimaryValue:(NSArray*)list;
+ (NSArray*)toPrimaryValues:(NSArray*)lists;
+ (NSArray*)toTypes:(NSArray*)lists;

@end

@implementation ZXVCardResultParser

+ (ZXAddressBookParsedResult *)parse:(ZXResult *)result {
  // Although we should insist on the raw text ending with "END:VCARD", there's no reason
  // to throw out everything else we parsed just because this was omitted. In fact, Eclair
  // is doing just that, and we can't parse its contacts without this leniency.
  NSString * rawText = [result text];
  if (![rawText hasPrefix:@"BEGIN:VCARD"]) {
    return nil;
  }
  NSMutableArray * names = [self matchVCardPrefixedField:@"FN" rawText:rawText trim:YES];
  if (names == nil) {
    // If no display names found, look for regular name fields and format them
    names = [self matchVCardPrefixedField:@"N" rawText:rawText trim:YES];
    [self formatNames:names];
  }
  NSArray * phoneNumbers = [self matchVCardPrefixedField:@"TEL" rawText:rawText trim:YES];
  NSArray * emails = [self matchVCardPrefixedField:@"EMAIL" rawText:rawText trim:YES];
  NSArray * note = [self matchSingleVCardPrefixedField:@"NOTE" rawText:rawText trim:NO];
  NSMutableArray * addresses = [self matchVCardPrefixedField:@"ADR" rawText:rawText trim:YES];
  if (addresses != nil) {
    for (int i = 0; i < [addresses count]; i++) {
      NSMutableArray * list = [addresses objectAtIndex:i];
      [list replaceObjectAtIndex:0 withObject:[self formatAddress:[list objectAtIndex:0]]];
    }
  }
  NSArray * org = [self matchSingleVCardPrefixedField:@"ORG" rawText:rawText trim:YES];
  NSArray * birthday = [self matchSingleVCardPrefixedField:@"BDAY" rawText:rawText trim:YES];
  if (birthday != nil && ![self isLikeVCardDate:[birthday objectAtIndex:0]]) {
    birthday = nil;
  }
  NSArray * title = [self matchSingleVCardPrefixedField:@"TITLE" rawText:rawText trim:YES];
  NSArray * url = [self matchSingleVCardPrefixedField:@"URL" rawText:rawText trim:YES];
  NSArray * instantMessenger = [self matchSingleVCardPrefixedField:@"IMPP" rawText:rawText trim:YES];
  return [[[ZXAddressBookParsedResult alloc] initWithNames:[self toPrimaryValues:names]
                                             pronunciation:nil
                                              phoneNumbers:[self toPrimaryValues:phoneNumbers]
                                                phoneTypes:[self toTypes:phoneNumbers]
                                                    emails:[self toPrimaryValues:emails]
                                                emailTypes:[self toTypes:emails]
                                          instantMessenger:[self toPrimaryValue:instantMessenger]
                                                      note:[self toPrimaryValue:note]
                                                 addresses:[self toPrimaryValues:addresses]
                                              addressTypes:[self toTypes:addresses]
                                                       org:[self toPrimaryValue:org]
                                                  birthday:[self toPrimaryValue:birthday]
                                                     title:[self toPrimaryValue:title]
                                                       url:[self toPrimaryValue:url]] autorelease];
}

+ (NSMutableArray *)matchVCardPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim {
  NSMutableArray * matches = nil;
  int i = 0;
  int max = [rawText length];

  while (i < max) {
    i = [rawText rangeOfString:prefix options:NSLiteralSearch range:NSMakeRange(i, [rawText length] - i)].location;
    if (i == NSNotFound) {
      break;
    }

    if (i > 0 && [rawText characterAtIndex:i - 1] != '\n') {
      i++;
      continue;
    }
    i += [prefix length];
    if ([rawText characterAtIndex:i] != ':' && [rawText characterAtIndex:i] != ';') {
      continue;
    }

    int metadataStart = i;
    while ([rawText characterAtIndex:i] != ':') {
      i++;
    }

    NSMutableArray* metadata = nil;
    BOOL quotedPrintable = NO;
    NSString * quotedPrintableCharset = nil;
    if (i > metadataStart) {
      for (int j = metadataStart + 1; j <= i; j++) {
        unichar c = [rawText characterAtIndex:j];
        if (c == ';' || c == ':') {
          NSString * metadatum = [rawText substringWithRange:NSMakeRange(metadataStart+1, j - metadataStart - 1)];
          if (metadata == nil) {
            metadata = [NSMutableArray arrayWithCapacity:1];
          }
          [metadata addObject:metadatum];
          int equals = [metadatum rangeOfString:@"=" options:NSCaseInsensitiveSearch].location;
          if (equals != NSNotFound) {
            NSString * key = [metadatum substringToIndex:equals];
            NSString * value = [metadatum substringFromIndex:equals + 1];
            if ([@"ENCODING" caseInsensitiveCompare:key] == NSOrderedSame) {
              if ([@"QUOTED-PRINTABLE" caseInsensitiveCompare:value] == NSOrderedSame) {
                quotedPrintable = YES;
              }
            } else if ([@"CHARSET" caseInsensitiveCompare:key] == NSOrderedSame) {
              quotedPrintableCharset = value;
            }
          }
          metadataStart = j;
        }
      }
    }

    i++;

    int matchStart = i;

    while ((i = [rawText rangeOfString:@"\n" options:NSLiteralSearch range:NSMakeRange(i, [rawText length] - i)].location) != NSNotFound) {
      if (i < [rawText length] - 1 && ([rawText characterAtIndex:i + 1] == ' ' || [rawText characterAtIndex:i + 1] == '\t')) {
        i += 2;
      } else if (quotedPrintable && ([rawText characterAtIndex:i - 1] == '=' || [rawText characterAtIndex:i - 2] == '=')) {
        i++;
      } else {
        break;
      }
    }

    if (i < 0) {
      i = max;
    } else if (i > matchStart) {
      if (matches == nil) {
        matches = [NSMutableArray arrayWithCapacity:1];
      }
      if ([rawText characterAtIndex:i - 1] == '\r') {
        i--;
      }
      NSString * element = [rawText substringWithRange:NSMakeRange(matchStart, i - matchStart)];
      if (trim) {
        element = [element stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
      }
      if (quotedPrintable) {
        element = [self decodeQuotedPrintable:element charset:quotedPrintableCharset];
      } else {
        element = [self stripContinuationCRLF:element];
      }
      if (metadata == nil) {
        NSMutableArray* match = [NSMutableArray arrayWithObject:element];
        [matches addObject:match];
      } else {
        [metadata insertObject:element atIndex:0];
        [matches addObject:metadata];
      }
      i++;
    } else {
      i++;
    }
  }

  if (matches == nil || [matches count] == 0) {
    return nil;
  }
  return [[[self toStringArray:matches] mutableCopy] autorelease];
}

+ (NSString *)stripContinuationCRLF:(NSString *)value {
  int length = [value length];
  NSMutableString * result = [NSMutableString stringWithCapacity:length];
  BOOL lastWasLF = NO;

  for (int i = 0; i < length; i++) {
    if (lastWasLF) {
      lastWasLF = NO;
      continue;
    }
    unichar c = [value characterAtIndex:i];
    lastWasLF = NO;

    switch (c) {
    case '\n':
      lastWasLF = YES;
      break;
    case '\r':
      break;
    default:
      [result appendFormat:@"%C", c];
    }
  }

  return result;
}

+ (NSString *)decodeQuotedPrintable:(NSString *)value charset:(NSString *)charset {
  int length = [value length];
  NSMutableString * result = [NSMutableString stringWithCapacity:length];
  NSMutableData * fragmentBuffer = [NSMutableData data];

  for (int i = 0; i < length; i++) {
    unichar c = [value characterAtIndex:i];

    switch (c) {
    case '\r':
    case '\n':
      break;
    case '=':
      if (i < length - 2) {
        unichar nextChar = [value characterAtIndex:i + 1];
        if (nextChar == '\r' || nextChar == '\n') {
          // Ignore, it's just a continuation symbol
        } else {
          unichar nextNextChar = [value characterAtIndex:i + 2];

          int encodedByte = 16 * [self toHexValue:nextChar] + [self toHexValue:nextNextChar];
          [fragmentBuffer appendBytes:&encodedByte length:1];
          i += 2;
        }
      }
      break;
    default:
      [self maybeAppendFragment:fragmentBuffer charset:charset result:result];
      [result appendFormat:@"%C", c];
    }
  }

  [self maybeAppendFragment:fragmentBuffer charset:charset result:result];
  return result;
}

+ (int)toHexValue:(unichar)c {
  if (c >= '0' && c <= '9') {
    return c - '0';
  }
  if (c >= 'A' && c <= 'F') {
    return c - 'A' + 10;
  }
  if (c >= 'a' && c <= 'f') {
    return c - 'a' + 10;
  }
  @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid character." userInfo:nil];
}

+ (void)maybeAppendFragment:(NSMutableData *)fragmentBuffer charset:(NSString *)charset result:(NSMutableString *)result {
  if ([fragmentBuffer length] > 0) {
    NSString * fragment;
    if (charset == nil || CFStringConvertIANACharSetNameToEncoding((CFStringRef)charset) == kCFStringEncodingInvalidId) {
      fragment = [[[NSString alloc] initWithData:fragmentBuffer encoding:NSUTF8StringEncoding] autorelease];
    } else {
      fragment = [[[NSString alloc] initWithData:fragmentBuffer encoding:CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)charset))] autorelease];
    }
    [fragmentBuffer setLength:0];
    [result appendString:fragment];
  }
}

+ (NSArray *)matchSingleVCardPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim {
  NSArray * values = [self matchVCardPrefixedField:prefix rawText:rawText trim:trim];
  return values == nil ? nil : [values objectAtIndex:0];
}

+ (NSString*)toPrimaryValue:(NSArray*)list {
  return list == nil || list.count == 0 ? nil : [list objectAtIndex:0];
}

+ (NSArray*)toPrimaryValues:(NSArray*)lists {
  if (lists == nil || lists.count == 0) {
    return nil;
  }
  NSMutableArray * result = [NSMutableArray arrayWithCapacity:lists.count];
  for (NSArray* list in lists) {
    [result addObject:[list objectAtIndex:0]];
  }
  return [self toStringArray:result];
}

+ (NSArray*)toTypes:(NSArray*)lists {
  if (lists == nil || lists.count == 0) {
    return nil;
  }
  NSMutableArray * result = [NSMutableArray arrayWithCapacity:lists.count];
  for (NSArray* list in lists) {
    NSString * type = nil;
    for (int i = 1; i < list.count; i++) {
      NSString * metadatum = [list objectAtIndex:i];
      int equals = [metadatum rangeOfString:@"=" options:NSCaseInsensitiveSearch].location;
      if (equals == NSNotFound) {
        // take the whole thing as a usable label
        type = metadatum;
        break;
      }
      if ([@"TYPE" isEqualToString:[[metadatum substringToIndex:equals] uppercaseString]]) {
        type = [metadatum substringFromIndex:equals + 1];
        break;
      }
    }
    [result addObject:type];
  }
  return [self toStringArray:result];
}

+ (BOOL)isLikeVCardDate:(NSString *)value {
  if (value == nil) {
    return YES;
  }
  if ([self isStringOfDigits:value length:8]) {
    return YES;
  }
  return [value length] == 10 && [value characterAtIndex:4] == '-' && [value characterAtIndex:7] == '-' && [self isSubstringOfDigits:value offset:0 length:4] && [self isSubstringOfDigits:value offset:5 length:2] && [self isSubstringOfDigits:value offset:8 length:2];
}

+ (NSString *)formatAddress:(NSString *)address {
  if (address == nil) {
    return nil;
  }
  int length = [address length];
  NSMutableString * newAddress = [NSMutableString stringWithCapacity:length];
  for (int j = 0; j < length; j++) {
    unichar c = [address characterAtIndex:j];
    if (c == ';') {
      [newAddress appendString:@" "];
    } else {
      [newAddress appendFormat:@"%C", c];
    }
  }

  return [newAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


/**
 * Formats name fields of the form "Public;John;Q.;Reverend;III" into a form like
 * "Reverend John Q. Public III".
 */
+ (void)formatNames:(NSMutableArray *)names {
  if (names != nil) {
    for (int i = 0; i < [names count]; i++) {
      NSMutableArray * list = [names objectAtIndex:i];
      NSString * name = [list objectAtIndex:i];
      NSMutableArray * components = [NSMutableArray arrayWithCapacity:5];
      int start = 0;
      int end;
      while ((end = [name rangeOfString:@";" options:NSLiteralSearch range:NSMakeRange(start, [name length] - start)].location) != NSNotFound && end > 0) {
        [components addObject:[name substringWithRange:NSMakeRange(start, [name length] - end - 1)]];
        start = end + 1;
      }

      [components addObject:[name substringFromIndex:start]];
      NSMutableString * newName = [NSMutableString stringWithCapacity:100];
      [self maybeAppendComponent:components i:3 newName:newName];
      [self maybeAppendComponent:components i:1 newName:newName];
      [self maybeAppendComponent:components i:2 newName:newName];
      [self maybeAppendComponent:components i:0 newName:newName];
      [self maybeAppendComponent:components i:4 newName:newName];
      [list replaceObjectAtIndex:0 withObject:[newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
  }
}

+ (void)maybeAppendComponent:(NSArray *)components i:(int)i newName:(NSMutableString *)newName {
  if ([components count] > i && [components objectAtIndex:i]) {
    [newName appendFormat:@" %@", [components objectAtIndex:i]];
  }
}

@end

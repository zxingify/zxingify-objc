#import "AddressBookParsedResult.h"
#import "Result.h"
#import "VCardResultParser.h"

@interface VCardResultParser ()

+ (NSString *) decodeQuotedPrintable:(NSString *)value charset:(NSString *)charset;
+ (NSString *) formatAddress:(NSString *)address;
+ (void) formatNames:(NSMutableArray *)names;
+ (BOOL) isLikeVCardDate:(NSString *)value;
+ (void) maybeAppendFragment:(NSOutputStream *)fragmentBuffer charset:(NSString *)charset result:(NSMutableString *)result;
+ (void) maybeAppendComponent:(NSArray *)components i:(int)i newName:(NSMutableString *)newName;
+ (NSMutableArray *) matchVCardPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim;
+ (NSString *) stripContinuationCRLF:(NSString *)value;
+ (int) toHexValue:(unichar)c;

@end

@implementation VCardResultParser

+ (AddressBookParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil || ![rawText hasPrefix:@"BEGIN:VCARD"]) {
    return nil;
  }
  NSMutableArray * names = [self matchVCardPrefixedField:@"FN" rawText:rawText trim:YES];
  if (names == nil) {
    names = [self matchVCardPrefixedField:@"N" rawText:rawText trim:YES];
    [self formatNames:names];
  }
  NSArray * phoneNumbers = [self matchVCardPrefixedField:@"TEL" rawText:rawText trim:YES];
  NSArray * emails = [self matchVCardPrefixedField:@"EMAIL" rawText:rawText trim:YES];
  NSString * note = [self matchSingleVCardPrefixedField:@"NOTE" rawText:rawText trim:NO];
  NSMutableArray * addresses = [self matchVCardPrefixedField:@"ADR" rawText:rawText trim:YES];
  if (addresses != nil) {
    for (int i = 0; i < [addresses count]; i++) {
      [addresses replaceObjectAtIndex:i withObject:[self formatAddress:[addresses objectAtIndex:i]]];
    }
  }
  NSString * org = [self matchSingleVCardPrefixedField:@"ORG" rawText:rawText trim:YES];
  NSString * birthday = [self matchSingleVCardPrefixedField:@"BDAY" rawText:rawText trim:YES];
  if (![self isLikeVCardDate:birthday]) {
    birthday = nil;
  }
  NSString * title = [self matchSingleVCardPrefixedField:@"TITLE" rawText:rawText trim:YES];
  NSString * url = [self matchSingleVCardPrefixedField:@"URL" rawText:rawText trim:YES];
  return [[[AddressBookParsedResult alloc] init:names
                                  pronunciation:nil
                                   phoneNumbers:phoneNumbers
                                         emails:emails
                                           note:note
                                      addresses:addresses
                                            org:org
                                       birthday:birthday
                                          title:title
                                            url:url] autorelease];
}

+ (NSMutableArray *) matchVCardPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim {
  NSMutableArray * matches = nil;
  int i = 0;
  int max = [rawText length];

  while (i < max) {
    i = [rawText rangeOfString:prefix options:NSLiteralSearch range:NSMakeRange(i, [rawText length] - i)].location;
    if (i < 0) {
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

    BOOL quotedPrintable = NO;
    NSString * quotedPrintableCharset = nil;
    if (i > metadataStart) {
      int j = metadataStart + 1;
      while (j <= i) {
        if ([rawText characterAtIndex:j] == ';' || [rawText characterAtIndex:j] == ':') {
          NSString * metadata = [rawText substringWithRange:NSMakeRange(metadataStart + 1, [rawText length] - j)];
          int equals = [metadata rangeOfString:@"="].location;
          if (equals >= 0) {
            NSString * key = [metadata substringToIndex:equals];
            NSString * value = [metadata substringFromIndex:equals + 1];
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
        j++;
      }
    }

    i++;

    int matchStart = i;

    while ((i = [rawText rangeOfString:@"\n" options:NSLiteralSearch range:NSMakeRange(i, [rawText length] - i)].location) >= 0) {
      if (i < [rawText length] - 1 && ([rawText characterAtIndex:i + 1] == ' ' || [rawText characterAtIndex:i + 1] == '\t')) {
        i += 2;
      }
       else if (quotedPrintable && ([rawText characterAtIndex:i - 1] == '=' || [rawText characterAtIndex:i - 2] == '=')) {
        i++;
      }
       else {
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
      NSString * element = [rawText substringWithRange:NSMakeRange(matchStart, [rawText length] - i)];
      if (trim) {
        element = [element stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
      }
      if (quotedPrintable) {
        element = [self decodeQuotedPrintable:element charset:quotedPrintableCharset];
      }
       else {
        element = [self stripContinuationCRLF:element];
      }
      [matches addObject:element];
      i++;
    } else {
      i++;
    }
  }

  if (matches == nil || [matches count] == 0) {
    return nil;
  }
  return matches;
}

+ (NSString *) stripContinuationCRLF:(NSString *)value {
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

+ (NSString *) decodeQuotedPrintable:(NSString *)value charset:(NSString *)charset {
  int length = [value length];
  NSMutableString * result = [NSMutableString stringWithCapacity:length];
  NSOutputStream * fragmentBuffer = [NSOutputStream outputStreamToMemory];
  [fragmentBuffer open];

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

          uint32_t encodedByte = (uint32_t)16 * [self toHexValue:nextChar] + [self toHexValue:nextNextChar];
          [fragmentBuffer write:(uint8_t *)&encodedByte maxLength:sizeof(encodedByte)];
          i += 2;
        }
      }
      break;
    default:
      [self maybeAppendFragment:fragmentBuffer charset:charset result:result];
      [fragmentBuffer close];
      fragmentBuffer = [NSOutputStream outputStreamToMemory];
      [fragmentBuffer open];
      [result appendFormat:@"%C", c];
    }
  }

  [self maybeAppendFragment:fragmentBuffer charset:charset result:result];
  [fragmentBuffer close];
  return result;
}

+ (int) toHexValue:(unichar)c {
  if (c >= '0' && c <= '9') {
    return c - '0';
  } else if (c >= 'A' && c <= 'F') {
    return c - 'A' + 10;
  } else if (c >= 'a' && c <= 'f') {
    return c - 'a' + 10;
  }
  @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid character." userInfo:nil];
}

+ (void) maybeAppendFragment:(NSOutputStream *)fragmentBuffer charset:(NSString *)charset result:(NSMutableString *)result {
  NSData *data = [fragmentBuffer propertyForKey:NSStreamDataWrittenToMemoryStreamKey];

  if ([data length] > 0) {
    NSString * fragment;
    if (charset == nil || CFStringConvertIANACharSetNameToEncoding((CFStringRef)charset) == kCFStringEncodingInvalidId) {
      fragment = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    } else {
      fragment = [[[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)charset))] autorelease];
    }
    [result appendString:fragment];
  }
}

+ (NSString *) matchSingleVCardPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim {
  NSArray * values = [self matchVCardPrefixedField:prefix rawText:rawText trim:trim];
  return values == nil ? nil : [values objectAtIndex:0];
}

+ (BOOL) isLikeVCardDate:(NSString *)value {
  if (value == nil) {
    return YES;
  }
  if ([self isStringOfDigits:value length:8]) {
    return YES;
  }
  return [value length] == 10 && [value characterAtIndex:4] == '-' && [value characterAtIndex:7] == '-' && [self isSubstringOfDigits:value offset:0 length:4] && [self isSubstringOfDigits:value offset:5 length:2] && [self isSubstringOfDigits:value offset:8 length:2];
}

+ (NSString *) formatAddress:(NSString *)address {
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
 * 
 * @param names name values to format, in place
 */
+ (void) formatNames:(NSMutableArray *)names {
  if (names != nil) {
    for (int i = 0; i < [names count]; i++) {
      NSString *name = [names objectAtIndex:i];
      NSMutableArray * components = [NSMutableArray arrayWithCapacity:5];
      int start = 0;
      int end;
      while ((end = [name rangeOfString:@";" options:NSLiteralSearch range:NSMakeRange(start, [name length] - start)].location) > 0) {
        [components addObject:[name substringWithRange:NSMakeRange(start, [name length] - end)]];
        start = end + 1;
      }

      [components addObject:[name substringFromIndex:start]];
      NSMutableString * newName = [NSMutableString stringWithCapacity:100];
      [self maybeAppendComponent:components i:3 newName:newName];
      [self maybeAppendComponent:components i:1 newName:newName];
      [self maybeAppendComponent:components i:2 newName:newName];
      [self maybeAppendComponent:components i:0 newName:newName];
      [self maybeAppendComponent:components i:4 newName:newName];
      [names replaceObjectAtIndex:i withObject:[newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
  }
}

+ (void) maybeAppendComponent:(NSArray *)components i:(int)i newName:(NSMutableString *)newName {
  if ([components objectAtIndex:i]) {
    [newName appendFormat:@" %@", [components objectAtIndex:i]];
  }
}

@end

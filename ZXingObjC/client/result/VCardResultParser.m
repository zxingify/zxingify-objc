#import "VCardResultParser.h"

@implementation VCardResultParser

+ (AddressBookParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil || ![rawText hasPrefix:@"BEGIN:VCARD"]) {
    return nil;
  }
  NSArray * names = [self matchVCardPrefixedField:@"FN" rawText:rawText trim:YES];
  if (names == nil) {
    names = [self matchVCardPrefixedField:@"N" rawText:rawText trim:YES];
    [self formatNames:names];
  }
  NSArray * phoneNumbers = [self matchVCardPrefixedField:@"TEL" rawText:rawText trim:YES];
  NSArray * emails = [self matchVCardPrefixedField:@"EMAIL" rawText:rawText trim:YES];
  NSString * note = [self matchSingleVCardPrefixedField:@"NOTE" rawText:rawText trim:NO];
  NSArray * addresses = [self matchVCardPrefixedField:@"ADR" rawText:rawText trim:YES];
  if (addresses != nil) {

    for (int i = 0; i < addresses.length; i++) {
      addresses[i] = [self formatAddress:addresses[i]];
    }

  }
  NSString * org = [self matchSingleVCardPrefixedField:@"ORG" rawText:rawText trim:YES];
  NSString * birthday = [self matchSingleVCardPrefixedField:@"BDAY" rawText:rawText trim:YES];
  if (![self isLikeVCardDate:birthday]) {
    birthday = nil;
  }
  NSString * title = [self matchSingleVCardPrefixedField:@"TITLE" rawText:rawText trim:YES];
  NSString * url = [self matchSingleVCardPrefixedField:@"URL" rawText:rawText trim:YES];
  return [[[AddressBookParsedResult alloc] init:names param1:nil param2:phoneNumbers param3:emails param4:note param5:addresses param6:org param7:birthday param8:title param9:url] autorelease];
}

+ (NSArray *) matchVCardPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim {
  NSMutableArray * matches = nil;
  int i = 0;
  int max = [rawText length];

  while (i < max) {
    i = [rawText rangeOfString:prefix param1:i];
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
          NSString * metadata = [rawText substringFromIndex:metadataStart + 1 param1:j];
          int equals = [metadata rangeOfString:'='];
          if (equals >= 0) {
            NSString * key = [metadata substringFromIndex:0 param1:equals];
            NSString * value = [metadata substringFromIndex:equals + 1];
            if ([@"ENCODING" equalsIgnoreCase:key]) {
              if ([@"QUOTED-PRINTABLE" equalsIgnoreCase:value]) {
                quotedPrintable = YES;
              }
            }
             else if ([@"CHARSET" equalsIgnoreCase:key]) {
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

    while ((i = [rawText rangeOfString:(int)'\n' param1:i]) >= 0) {
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
    }
     else if (i > matchStart) {
      if (matches == nil) {
        matches = [[[NSMutableArray alloc] init:1] autorelease];
      }
      if ([rawText characterAtIndex:i - 1] == '\r') {
        i--;
      }
      NSString * element = [rawText substringFromIndex:matchStart param1:i];
      if (trim) {
        element = [element stringByTrimmingCharactersInSet];
      }
      if (quotedPrintable) {
        element = [self decodeQuotedPrintable:element charset:quotedPrintableCharset];
      }
       else {
        element = [self stripContinuationCRLF:element];
      }
      [matches addObject:element];
      i++;
    }
     else {
      i++;
    }
  }

  if (matches == nil || [matches empty]) {
    return nil;
  }
  return [self toStringArray:matches];
}

+ (NSString *) stripContinuationCRLF:(NSString *)value {
  int length = [value length];
  NSMutableString * result = [[[NSMutableString alloc] init:length] autorelease];
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
      [result append:c];
    }
  }

  return [result description];
}

+ (NSString *) decodeQuotedPrintable:(NSString *)value charset:(NSString *)charset {
  int length = [value length];
  NSMutableString * result = [[[NSMutableString alloc] init:length] autorelease];
  ByteArrayOutputStream * fragmentBuffer = [[[ByteArrayOutputStream alloc] init] autorelease];

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
        }
         else {
          unichar nextNextChar = [value characterAtIndex:i + 2];

          @try {
            int encodedByte = 16 * [self toHexValue:nextChar] + [self toHexValue:nextNextChar];
            [fragmentBuffer write:encodedByte];
          }
          @catch (IllegalArgumentException * iae) {
          }
          i += 2;
        }
      }
      break;
    default:
      [self maybeAppendFragment:fragmentBuffer charset:charset result:result];
      [result append:c];
    }
  }

  [self maybeAppendFragment:fragmentBuffer charset:charset result:result];
  return [result description];
}

+ (int) toHexValue:(unichar)c {
  if (c >= '0' && c <= '9') {
    return c - '0';
  }
   else if (c >= 'A' && c <= 'F') {
    return c - 'A' + 10;
  }
   else if (c >= 'a' && c <= 'f') {
    return c - 'a' + 10;
  }
  @throw [[[IllegalArgumentException alloc] init] autorelease];
}

+ (void) maybeAppendFragment:(ByteArrayOutputStream *)fragmentBuffer charset:(NSString *)charset result:(NSMutableString *)result {
  if ([fragmentBuffer size] > 0) {
    NSArray * fragmentBytes = [fragmentBuffer toByteArray];
    NSString * fragment;
    if (charset == nil) {
      fragment = [[[NSString alloc] init:fragmentBytes] autorelease];
    }
     else {

      @try {
        fragment = [[[NSString alloc] init:fragmentBytes param1:charset] autorelease];
      }
      @catch (UnsupportedEncodingException * e) {
        fragment = [[[NSString alloc] init:fragmentBytes] autorelease];
      }
    }
    [fragmentBuffer reset];
    [result append:fragment];
  }
}

+ (NSString *) matchSingleVCardPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim {
  NSArray * values = [self matchVCardPrefixedField:prefix rawText:rawText trim:trim];
  return values == nil ? nil : values[0];
}

+ (BOOL) isLikeVCardDate:(NSString *)value {
  if (value == nil) {
    return YES;
  }
  if ([self isStringOfDigits:value param1:8]) {
    return YES;
  }
  return [value length] == 10 && [value characterAtIndex:4] == '-' && [value characterAtIndex:7] == '-' && [self isSubstringOfDigits:value param1:0 param2:4] && [self isSubstringOfDigits:value param1:5 param2:2] && [self isSubstringOfDigits:value param1:8 param2:2];
}

+ (NSString *) formatAddress:(NSString *)address {
  if (address == nil) {
    return nil;
  }
  int length = [address length];
  NSMutableString * newAddress = [[[NSMutableString alloc] init:length] autorelease];

  for (int j = 0; j < length; j++) {
    unichar c = [address characterAtIndex:j];
    if (c == ';') {
      [newAddress append:' '];
    }
     else {
      [newAddress append:c];
    }
  }

  return [[newAddress description] trim];
}


/**
 * Formats name fields of the form "Public;John;Q.;Reverend;III" into a form like
 * "Reverend John Q. Public III".
 * 
 * @param names name values to format, in place
 */
+ (void) formatNames:(NSArray *)names {
  if (names != nil) {

    for (int i = 0; i < names.length; i++) {
      NSString * name = names[i];
      NSArray * components = [NSArray array];
      int start = 0;
      int end;
      int componentIndex = 0;

      while ((end = [name rangeOfString:';' param1:start]) > 0) {
        components[componentIndex] = [name substringFromIndex:start param1:end];
        componentIndex++;
        start = end + 1;
      }

      components[componentIndex] = [name substringFromIndex:start];
      NSMutableString * newName = [[[NSMutableString alloc] init:100] autorelease];
      [self maybeAppendComponent:components i:3 newName:newName];
      [self maybeAppendComponent:components i:1 newName:newName];
      [self maybeAppendComponent:components i:2 newName:newName];
      [self maybeAppendComponent:components i:0 newName:newName];
      [self maybeAppendComponent:components i:4 newName:newName];
      names[i] = [[newName description] trim];
    }

  }
}

+ (void) maybeAppendComponent:(NSArray *)components i:(int)i newName:(NSMutableString *)newName {
  if (components[i] != nil) {
    [newName append:' '];
    [newName append:components[i]];
  }
}

@end

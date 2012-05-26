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

#import "ZXEmailAddressParsedResult.h"
#import "ZXEmailDoCoMoResultParser.h"
#import "ZXResult.h"

const unichar ATEXT_SYMBOLS[21] = {'@','.','!','#','$','%','&','\'','*','+','-','/','=','?','^','_','`','{','|','}','~'};

@interface ZXEmailDoCoMoResultParser ()

+ (BOOL)isAtextSymbol:(unichar)c;

@end

@implementation ZXEmailDoCoMoResultParser

+ (ZXEmailAddressParsedResult *) parse:(ZXResult *)result {
  NSString * rawText = [result text];
  if (rawText == nil || ![rawText hasPrefix:@"MATMSG:"]) {
    return nil;
  }
  NSArray * rawTo = [self matchDoCoMoPrefixedField:@"TO:" rawText:rawText trim:YES];
  if (rawTo == nil) {
    return nil;
  }
  NSString * to = [rawTo objectAtIndex:0];
  if (![self isBasicallyValidEmailAddress:to]) {
    return nil;
  }
  NSString * subject = [self matchSingleDoCoMoPrefixedField:@"SUB:" rawText:rawText trim:NO];
  NSString * body = [self matchSingleDoCoMoPrefixedField:@"BODY:" rawText:rawText trim:NO];

  return [[[ZXEmailAddressParsedResult alloc] initWithEmailAddress:to
                                                           subject:subject
                                                              body:body
                                                         mailtoURI:[@"mailto:" stringByAppendingString:to]] autorelease];
}


/**
 * This implements only the most basic checking for an email address's validity -- that it contains
 * an '@' contains no characters disallowed by RFC 2822. This is an overly lenient definition of
 * validity. We want to generally be lenient here since this class is only intended to encapsulate what's
 * in a barcode, not "judge" it.
 */
+ (BOOL)isBasicallyValidEmailAddress:(NSString *)email {
  if (email == nil) {
    return NO;
  }
  BOOL atFound = NO;
  for (int i = 0; i < [email length]; i++) {
    unichar c = [email characterAtIndex:i];
    if ((c < 'a' || c > 'z') && (c < 'A' || c > 'Z') && (c < '0' || c > '9') && ![self isAtextSymbol:c]) {
      return NO;
    }
    if (c == '@') {
      if (atFound) {
        return NO;
      }
      atFound = YES;
    }
  }
  return atFound;
}

+ (BOOL)isAtextSymbol:(unichar)c {
  for (int i = 0; i < sizeof(ATEXT_SYMBOLS) / sizeof(unichar); i++) {
    if (c == ATEXT_SYMBOLS[i]) {
      return YES;
    }
  }

  return NO;
}

@end

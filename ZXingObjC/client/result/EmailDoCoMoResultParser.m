#import "EmailAddressParsedResult.h"
#import "EmailDoCoMoResultParser.h"
#import "Result.h"

const unichar ATEXT_SYMBOLS[21] = {'@','.','!','#','$','%','&','\'','*','+','-','/','=','?','^','_','`','{','|','}','~'};

@interface EmailDoCoMoResultParser ()

+ (BOOL) isAtextSymbol:(unichar)c;

@end

@implementation EmailDoCoMoResultParser

+ (EmailAddressParsedResult *) parse:(Result *)result {
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
  return [[[EmailAddressParsedResult alloc] init:to subject:subject body:body mailtoURI:[@"mailto:" stringByAppendingString:to]] autorelease];
}


/**
 * This implements only the most basic checking for an email address's validity -- that it contains
 * an '@' contains no characters disallowed by RFC 2822. This is an overly lenient definition of
 * validity. We want to generally be lenient here since this class is only intended to encapsulate what's
 * in a barcode, not "judge" it.
 */
+ (BOOL) isBasicallyValidEmailAddress:(NSString *)email {
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

+ (BOOL) isAtextSymbol:(unichar)c {

  for (int i = 0; i < sizeof(ATEXT_SYMBOLS) / sizeof(unichar); i++) {
    if (c == ATEXT_SYMBOLS[i]) {
      return YES;
    }
  }

  return NO;
}

@end

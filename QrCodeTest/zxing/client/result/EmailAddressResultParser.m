#import "EmailAddressResultParser.h"

@implementation EmailAddressResultParser

+ (EmailAddressParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil) {
    return nil;
  }
  NSString * emailAddress;
  if ([rawText hasPrefix:@"mailto:"] || [rawText hasPrefix:@"MAILTO:"]) {
    emailAddress = [rawText substringFromIndex:7];
    int queryStart = [emailAddress rangeOfString:'?'];
    if (queryStart >= 0) {
      emailAddress = [emailAddress substringFromIndex:0 param1:queryStart];
    }
    NSMutableDictionary * nameValues = [self parseNameValuePairs:rawText];
    NSString * subject = nil;
    NSString * body = nil;
    if (nameValues != nil) {
      if ([emailAddress length] == 0) {
        emailAddress = (NSString *)[nameValues objectForKey:@"to"];
      }
      subject = (NSString *)[nameValues objectForKey:@"subject"];
      body = (NSString *)[nameValues objectForKey:@"body"];
    }
    return [[[EmailAddressParsedResult alloc] init:emailAddress param1:subject param2:body param3:rawText] autorelease];
  }
   else {
    if (![EmailDoCoMoResultParser isBasicallyValidEmailAddress:rawText]) {
      return nil;
    }
    emailAddress = rawText;
    return [[[EmailAddressParsedResult alloc] init:emailAddress param1:nil param2:nil param3:[@"mailto:" stringByAppendingString:emailAddress]] autorelease];
  }
}

@end

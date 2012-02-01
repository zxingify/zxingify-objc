#import "EmailAddressParsedResult.h"
#import "EmailAddressResultParser.h"
#import "EmailDoCoMoResultParser.h"
#import "Result.h"

@implementation EmailAddressResultParser

+ (EmailAddressParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil) {
    return nil;
  }
  NSString * emailAddress;
  if ([rawText hasPrefix:@"mailto:"] || [rawText hasPrefix:@"MAILTO:"]) {
    emailAddress = [rawText substringFromIndex:7];
    int queryStart = [emailAddress rangeOfString:@"?"].location;
    if (queryStart >= 0) {
      emailAddress = [emailAddress substringToIndex:queryStart];
    }
    NSMutableDictionary * nameValues = [self parseNameValuePairs:rawText];
    NSString * subject = nil;
    NSString * body = nil;
    if (nameValues != nil) {
      if ([emailAddress length] == 0) {
        emailAddress = [nameValues objectForKey:@"to"];
      }
      subject = [nameValues objectForKey:@"subject"];
      body = [nameValues objectForKey:@"body"];
    }
    return [[[EmailAddressParsedResult alloc] init:emailAddress subject:subject body:body mailtoURI:rawText] autorelease];
  } else {
    if (![EmailDoCoMoResultParser isBasicallyValidEmailAddress:rawText]) {
      return nil;
    }
    emailAddress = rawText;
    return [[[EmailAddressParsedResult alloc] init:emailAddress subject:nil body:nil mailtoURI:[@"mailto:" stringByAppendingString:emailAddress]] autorelease];
  }
}

@end

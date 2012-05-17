#import "ZXEmailAddressParsedResult.h"
#import "ZXEmailAddressResultParser.h"
#import "ZXEmailDoCoMoResultParser.h"
#import "ZXResult.h"

@implementation ZXEmailAddressResultParser

+ (ZXEmailAddressParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = [result text];
  if (rawText == nil) {
    return nil;
  }
  NSString * emailAddress;
  if ([rawText hasPrefix:@"mailto:"] || [rawText hasPrefix:@"MAILTO:"]) {
    emailAddress = [rawText substringFromIndex:7];
    int queryStart = [emailAddress rangeOfString:@"?"].location;
    if (queryStart != NSNotFound) {
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
    return [[[ZXEmailAddressParsedResult alloc] initWithEmailAddress:emailAddress
                                                             subject:subject
                                                                body:body
                                                           mailtoURI:rawText] autorelease];
  } else {
    if (![ZXEmailDoCoMoResultParser isBasicallyValidEmailAddress:rawText]) {
      return nil;
    }
    emailAddress = rawText;
    return [[[ZXEmailAddressParsedResult alloc] initWithEmailAddress:emailAddress
                                                             subject:nil
                                                                body:nil
                                                           mailtoURI:[@"mailto:" stringByAppendingString:emailAddress]] autorelease];
  }
}

@end

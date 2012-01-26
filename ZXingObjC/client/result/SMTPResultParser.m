#import "EmailAddressParsedResult.h"
#import "SMTPResultParser.h"

@implementation SMTPResultParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (EmailAddressParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil) {
    return nil;
  }
  if (!([rawText hasPrefix:@"smtp:"] || [rawText hasPrefix:@"SMTP:"])) {
    return nil;
  }
  NSString * emailAddress = [rawText substringFromIndex:5];
  NSString * subject = nil;
  NSString * body = nil;
  int colon = [emailAddress rangeOfString:':'];
  if (colon >= 0) {
    subject = [emailAddress substringFromIndex:colon + 1];
    emailAddress = [emailAddress substringFromIndex:0 param1:colon];
    colon = [subject rangeOfString:':'];
    if (colon >= 0) {
      body = [subject substringFromIndex:colon + 1];
      subject = [subject substringFromIndex:0 param1:colon];
    }
  }
  NSString * mailtoURI = [@"mailto:" stringByAppendingString:emailAddress];
  return [[[EmailAddressParsedResult alloc] init:emailAddress param1:subject param2:body param3:mailtoURI] autorelease];
}

@end

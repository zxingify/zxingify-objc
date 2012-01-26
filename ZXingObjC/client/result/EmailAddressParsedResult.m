#import "EmailAddressParsedResult.h"

@implementation EmailAddressParsedResult

@synthesize emailAddress;
@synthesize subject;
@synthesize body;
@synthesize mailtoURI;
@synthesize displayResult;

- (id) init:(NSString *)emailAddress subject:(NSString *)subject body:(NSString *)body mailtoURI:(NSString *)mailtoURI {
  if (self = [super init:ParsedResultType.EMAIL_ADDRESS]) {
    emailAddress = emailAddress;
    subject = subject;
    body = body;
    mailtoURI = mailtoURI;
  }
  return self;
}

- (NSString *) displayResult {
  StringBuffer * result = [[[StringBuffer alloc] init:30] autorelease];
  [self maybeAppend:emailAddress param1:result];
  [self maybeAppend:subject param1:result];
  [self maybeAppend:body param1:result];
  return [result description];
}

- (void) dealloc {
  [emailAddress release];
  [subject release];
  [body release];
  [mailtoURI release];
  [super dealloc];
}

@end

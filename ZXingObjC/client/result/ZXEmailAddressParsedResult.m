#import "ZXEmailAddressParsedResult.h"
#import "ZXParsedResultType.h"

@interface ZXEmailAddressParsedResult ()

@property(nonatomic, retain) NSString * emailAddress;
@property(nonatomic, retain) NSString * subject;
@property(nonatomic, retain) NSString * body;
@property(nonatomic, retain) NSString * mailtoURI;
@property(nonatomic, retain) NSString * displayResult;

@end

@implementation ZXEmailAddressParsedResult

@synthesize emailAddress;
@synthesize subject;
@synthesize body;
@synthesize mailtoURI;
@synthesize displayResult;

- (id) init:(NSString *)anEmailAddress subject:(NSString *)aSubject body:(NSString *)aBody mailtoURI:(NSString *)aMailtoURI {
  if (self = [super initWithType:kParsedResultTypeEmailAddress]) {
    self.emailAddress = anEmailAddress;
    self.subject = aSubject;
    self.body = aBody;
    self.mailtoURI = aMailtoURI;
  }
  return self;
}

- (NSString *) displayResult {
  NSMutableString * result = [NSMutableString stringWithCapacity:30];
  [ZXParsedResult maybeAppend:emailAddress result:result];
  [ZXParsedResult maybeAppend:subject result:result];
  [ZXParsedResult maybeAppend:body result:result];
  return result;
}

- (void) dealloc {
  [emailAddress release];
  [subject release];
  [body release];
  [mailtoURI release];
  [super dealloc];
}

@end

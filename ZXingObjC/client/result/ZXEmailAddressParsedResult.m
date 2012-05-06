#import "ZXEmailAddressParsedResult.h"
#import "ZXParsedResultType.h"

@interface ZXEmailAddressParsedResult ()

@property (nonatomic, copy) NSString * emailAddress;
@property (nonatomic, copy) NSString * subject;
@property (nonatomic, copy) NSString * body;
@property (nonatomic, copy) NSString * mailtoURI;

@end

@implementation ZXEmailAddressParsedResult

@synthesize emailAddress;
@synthesize subject;
@synthesize body;
@synthesize mailtoURI;

- (id)initWithEmailAddress:(NSString *)anEmailAddress subject:(NSString *)aSubject body:(NSString *)aBody mailtoURI:(NSString *)aMailtoURI {
  self = [super initWithType:kParsedResultTypeEmailAddress];
  if (self) {
    self.emailAddress = anEmailAddress;
    self.subject = aSubject;
    self.body = aBody;
    self.mailtoURI = aMailtoURI;
  }

  return self;
}

- (void) dealloc {
  [emailAddress release];
  [subject release];
  [body release];
  [mailtoURI release];
  
  [super dealloc];
}

- (NSString *)displayResult {
  NSMutableString * result = [NSMutableString stringWithCapacity:30];
  [ZXParsedResult maybeAppend:emailAddress result:result];
  [ZXParsedResult maybeAppend:subject result:result];
  [ZXParsedResult maybeAppend:body result:result];
  return [NSString stringWithString:result];
}

@end

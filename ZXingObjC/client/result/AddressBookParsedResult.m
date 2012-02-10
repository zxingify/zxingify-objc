#import "AddressBookParsedResult.h"
#import "ParsedResultType.h"

@implementation AddressBookParsedResult

@synthesize names;
@synthesize pronunciation;
@synthesize phoneNumbers;
@synthesize emails;
@synthesize note;
@synthesize addresses;
@synthesize title;
@synthesize org;
@synthesize uRL;
@synthesize birthday;
@synthesize displayResult;

- (id) init:(NSArray *)aNames pronunciation:(NSString *)aPronunciation phoneNumbers:(NSArray *)aPhoneNumbers emails:(NSArray *)aEmails note:(NSString *)aNote addresses:(NSArray *)anAddresses org:(NSString *)anOrg birthday:(NSString *)aBirthday title:(NSString *)aTitle url:(NSString *)aUrl {
  if (self = [super initWithType:kParsedResultTypeAddressBook]) {
    self.names = aNames;
    self.pronunciation = aPronunciation;
    self.phoneNumbers = aPhoneNumbers;
    self.emails = aEmails;
    self.note = aNote;
    self.addresses = anAddresses;
    self.org = anOrg;
    self.birthday = aBirthday;
    self.title = aTitle;
    self.uRL = aUrl;
  }
  return self;
}

- (NSString *) displayResult {
  NSMutableString * result = [NSMutableString string];
  [ParsedResult maybeAppendArray:names result:result];
  [ParsedResult maybeAppend:pronunciation result:result];
  [ParsedResult maybeAppend:title result:result];
  [ParsedResult maybeAppend:org result:result];
  [ParsedResult maybeAppendArray:addresses result:result];
  [ParsedResult maybeAppendArray:phoneNumbers result:result];
  [ParsedResult maybeAppendArray:emails result:result];
  [ParsedResult maybeAppend:uRL result:result];
  [ParsedResult maybeAppend:birthday result:result];
  [ParsedResult maybeAppend:note result:result];
  return result;
}

- (void) dealloc {
  [names release];
  [pronunciation release];
  [phoneNumbers release];
  [emails release];
  [note release];
  [addresses release];
  [org release];
  [birthday release];
  [title release];
  [uRL release];
  [super dealloc];
}

@end

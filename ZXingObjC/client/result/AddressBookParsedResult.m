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
  [self maybeAppendArray:names result:result];
  [self maybeAppend:pronunciation result:result];
  [self maybeAppend:title result:result];
  [self maybeAppend:org result:result];
  [self maybeAppendArray:addresses result:result];
  [self maybeAppendArray:phoneNumbers result:result];
  [self maybeAppendArray:emails result:result];
  [self maybeAppend:uRL result:result];
  [self maybeAppend:birthday result:result];
  [self maybeAppend:note result:result];
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

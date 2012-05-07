#import "ZXAddressBookParsedResult.h"
#import "ZXParsedResultType.h"

@interface ZXAddressBookParsedResult ()

@property (nonatomic, retain) NSArray * names;
@property (nonatomic, copy) NSString * pronunciation;
@property (nonatomic, retain) NSArray * phoneNumbers;
@property (nonatomic, retain) NSArray * emails;
@property (nonatomic, copy) NSString * note;
@property (nonatomic, retain) NSArray * addresses;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * org;
@property (nonatomic, copy) NSString * url;
@property (nonatomic, copy) NSString * birthday;

@end

@implementation ZXAddressBookParsedResult

@synthesize names;
@synthesize pronunciation;
@synthesize phoneNumbers;
@synthesize emails;
@synthesize note;
@synthesize addresses;
@synthesize title;
@synthesize org;
@synthesize url;
@synthesize birthday;

- (id)initWithNames:(NSArray *)aNames pronunciation:(NSString *)aPronunciation phoneNumbers:(NSArray *)aPhoneNumbers emails:(NSArray *)aEmails note:(NSString *)aNote addresses:(NSArray *)anAddresses org:(NSString *)anOrg birthday:(NSString *)aBirthday title:(NSString *)aTitle url:(NSString *)aUrl {
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
    self.url = aUrl;
  }

  return self;
}

- (void)dealloc {
  [names release];
  [pronunciation release];
  [phoneNumbers release];
  [emails release];
  [note release];
  [addresses release];
  [org release];
  [birthday release];
  [title release];
  [url release];

  [super dealloc];
}

- (NSString *)displayResult {
  NSMutableString * result = [NSMutableString string];
  [ZXParsedResult maybeAppendArray:self.names result:result];
  [ZXParsedResult maybeAppend:self.pronunciation result:result];
  [ZXParsedResult maybeAppend:self.title result:result];
  [ZXParsedResult maybeAppend:self.org result:result];
  [ZXParsedResult maybeAppendArray:self.addresses result:result];
  [ZXParsedResult maybeAppendArray:self.phoneNumbers result:result];
  [ZXParsedResult maybeAppendArray:self.emails result:result];
  [ZXParsedResult maybeAppend:self.url result:result];
  [ZXParsedResult maybeAppend:self.birthday result:result];
  [ZXParsedResult maybeAppend:self.note result:result];
  return [NSString stringWithString:result];
}

@end

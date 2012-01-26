#import "AddressBookParsedResult.h"

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

- (id) init:(NSArray *)names pronunciation:(NSString *)pronunciation phoneNumbers:(NSArray *)phoneNumbers emails:(NSArray *)emails note:(NSString *)note addresses:(NSArray *)addresses org:(NSString *)org birthday:(NSString *)birthday title:(NSString *)title url:(NSString *)url {
  if (self = [super init:ParsedResultType.ADDRESSBOOK]) {
    names = names;
    pronunciation = pronunciation;
    phoneNumbers = phoneNumbers;
    emails = emails;
    note = note;
    addresses = addresses;
    org = org;
    birthday = birthday;
    title = title;
    url = url;
  }
  return self;
}

- (NSString *) displayResult {
  StringBuffer * result = [[[StringBuffer alloc] init:100] autorelease];
  [self maybeAppend:names param1:result];
  [self maybeAppend:pronunciation param1:result];
  [self maybeAppend:title param1:result];
  [self maybeAppend:org param1:result];
  [self maybeAppend:addresses param1:result];
  [self maybeAppend:phoneNumbers param1:result];
  [self maybeAppend:emails param1:result];
  [self maybeAppend:url param1:result];
  [self maybeAppend:birthday param1:result];
  [self maybeAppend:note param1:result];
  return [result description];
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
  [url release];
  [super dealloc];
}

@end

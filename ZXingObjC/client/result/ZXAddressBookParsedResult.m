/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXAddressBookParsedResult.h"
#import "ZXParsedResultType.h"

@interface ZXAddressBookParsedResult ()

@property (nonatomic, retain) NSArray *names;
@property (nonatomic, retain) NSArray *nicknames;
@property (nonatomic, copy) NSString *pronunciation;
@property (nonatomic, retain) NSArray *phoneNumbers;
@property (nonatomic, retain) NSArray *phoneTypes;
@property (nonatomic, retain) NSArray *emails;
@property (nonatomic, retain) NSArray *emailTypes;
@property (nonatomic, copy) NSString *instantMessenger;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, retain) NSArray *addresses;
@property (nonatomic, retain) NSArray *addressTypes;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *org;
@property (nonatomic, retain) NSArray *urls;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, retain) NSArray *geo;

@end

@implementation ZXAddressBookParsedResult

@synthesize names;
@synthesize nicknames;
@synthesize pronunciation;
@synthesize phoneNumbers;
@synthesize phoneTypes;
@synthesize emails;
@synthesize emailTypes;
@synthesize instantMessenger;
@synthesize note;
@synthesize addresses;
@synthesize addressTypes;
@synthesize title;
@synthesize org;
@synthesize urls;
@synthesize birthday;
@synthesize geo;

- (id)initWithNames:(NSArray *)_names phoneNumbers:(NSArray *)_phoneNumbers
         phoneTypes:(NSArray *)_phoneTypes emails:(NSArray *)_emails emailTypes:(NSArray *)_emailTypes
          addresses:(NSArray *)_addresses addressTypes:(NSArray *)_addressTypes {
  return [self initWithNames:_names nicknames:nil pronunciation:nil phoneNumbers:_phoneNumbers phoneTypes:_phoneNumbers
                      emails:_emails emailTypes:_emailTypes instantMessenger:nil note:nil
                   addresses:_addresses addressTypes:_addressTypes org:nil birthday:nil title:nil urls:nil geo:nil];
}

- (id)initWithNames:(NSArray *)_names nicknames:(NSArray *)_nicknames pronunciation:(NSString *)_pronunciation
       phoneNumbers:(NSArray *)_phoneNumbers phoneTypes:(NSArray *)_phoneTypes emails:(NSArray *)_emails emailTypes:(NSArray *)_emailTypes
   instantMessenger:(NSString *)_instantMessenger note:(NSString *)_note addresses:(NSArray *)_addresses
       addressTypes:(NSArray *)_addressTypes org:(NSString *)_org birthday:(NSString *)_birthday
              title:(NSString *)_title urls:(NSArray *)_urls geo:(NSArray *)_geo {
  if (self = [super initWithType:kParsedResultTypeAddressBook]) {
    self.names = _names;
    self.nicknames = _nicknames;
    self.pronunciation = _pronunciation;
    self.phoneNumbers = _phoneNumbers;
    self.phoneTypes = _phoneTypes;
    self.emails = _emails;
    self.emailTypes = _emailTypes;
    self.instantMessenger = _instantMessenger;
    self.note = _note;
    self.addresses = _addresses;
    self.addressTypes = _addressTypes;
    self.org = _org;
    self.birthday = _birthday;
    self.title = _title;
    self.urls = _urls;
    self.geo = _geo;
  }

  return self;
}

+ (id)addressBookParsedResultWithNames:(NSArray *)names phoneNumbers:(NSArray *)phoneNumbers
                            phoneTypes:(NSArray *)phoneTypes emails:(NSArray *)emails emailTypes:(NSArray *)emailTypes
                             addresses:(NSArray *)addresses addressTypes:(NSArray *)addressTypes {
  return [[self alloc] initWithNames:names phoneNumbers:phoneNumbers phoneTypes:phoneTypes emails:emails
                          emailTypes:emailTypes addresses:addresses addressTypes:addressTypes];
}


+ (id)addressBookParsedResultWithNames:(NSArray *)names nicknames:(NSArray *)nicknames
                         pronunciation:(NSString *)pronunciation phoneNumbers:(NSArray *)phoneNumbers phoneTypes:(NSArray *)phoneTypes
                                emails:(NSArray *)emails emailTypes:(NSArray *)emailTypes instantMessenger:(NSString *)instantMessenger
                                  note:(NSString *)note addresses:(NSArray *)addresses addressTypes:(NSArray *)addressTypes org:(NSString *)org
                              birthday:(NSString *)birthday title:(NSString *)title urls:(NSArray *)urls geo:(NSArray *)geo {
  return [[[self alloc] initWithNames:names nicknames:nicknames pronunciation:pronunciation phoneNumbers:phoneNumbers
                           phoneTypes:phoneTypes emails:emails emailTypes:emailTypes
                     instantMessenger:instantMessenger note:note addresses:addresses
                         addressTypes:addressTypes org:org birthday:birthday title:title urls:urls geo:geo] autorelease];
}

- (void)dealloc {
  [names release];
  [nicknames release];
  [pronunciation release];
  [phoneNumbers release];
  [phoneTypes release];
  [emails release];
  [emailTypes release];
  [instantMessenger release];
  [note release];
  [addresses release];
  [addressTypes release];
  [org release];
  [birthday release];
  [title release];
  [urls release];
  [geo release];

  [super dealloc];
}

- (NSString *)displayResult {
  NSMutableString *result = [NSMutableString string];
  [ZXParsedResult maybeAppendArray:self.names result:result];
  [ZXParsedResult maybeAppendArray:self.nicknames result:result];
  [ZXParsedResult maybeAppend:self.pronunciation result:result];
  [ZXParsedResult maybeAppend:self.title result:result];
  [ZXParsedResult maybeAppend:self.org result:result];
  [ZXParsedResult maybeAppendArray:self.addresses result:result];
  [ZXParsedResult maybeAppendArray:self.phoneNumbers result:result];
  [ZXParsedResult maybeAppendArray:self.emails result:result];
  [ZXParsedResult maybeAppend:self.instantMessenger result:result];
  [ZXParsedResult maybeAppendArray:self.urls result:result];
  [ZXParsedResult maybeAppend:self.birthday result:result];
  [ZXParsedResult maybeAppendArray:self.geo result:result];
  [ZXParsedResult maybeAppend:self.note result:result];
  return result;
}

@end

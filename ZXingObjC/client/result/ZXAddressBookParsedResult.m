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

@property (nonatomic, retain) NSArray * names;
@property (nonatomic, copy) NSString * pronunciation;
@property (nonatomic, retain) NSArray * phoneNumbers;
@property (nonatomic, retain) NSArray * phoneTypes;
@property (nonatomic, retain) NSArray * emails;
@property (nonatomic, retain) NSArray * emailTypes;
@property (nonatomic, copy) NSString * instantMessenger;
@property (nonatomic, copy) NSString * note;
@property (nonatomic, retain) NSArray * addresses;
@property (nonatomic, retain) NSArray * addressTypes;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * org;
@property (nonatomic, copy) NSString * url;
@property (nonatomic, copy) NSString * birthday;

@end

@implementation ZXAddressBookParsedResult

@synthesize names;
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
@synthesize url;
@synthesize birthday;

- (id)initWithNames:(NSArray *)aNames pronunciation:(NSString *)aPronunciation phoneNumbers:(NSArray *)aPhoneNumbers
         phoneTypes:(NSArray *)aPhoneTypes emails:(NSArray *)anEmails emailTypes:(NSArray *)anEmailTypes
   instantMessenger:(NSString *)anInstantMessenger note:(NSString *)aNote addresses:(NSArray *)anAddresses
       addressTypes:(NSArray *)anAddressTypes org:(NSString *)anOrg birthday:(NSString *)aBirthday
              title:(NSString *)aTitle url:(NSString *)aUrl {
  if (self = [super initWithType:kParsedResultTypeAddressBook]) {
    self.names = aNames;
    self.pronunciation = aPronunciation;
    self.phoneNumbers = aPhoneNumbers;
    self.phoneTypes = aPhoneTypes;
    self.emails = anEmails;
    self.emailTypes = anEmailTypes;
    self.instantMessenger = anInstantMessenger;
    self.note = aNote;
    self.addresses = anAddresses;
    self.addressTypes = anAddressTypes;
    self.org = anOrg;
    self.birthday = aBirthday;
    self.title = aTitle;
    self.url = aUrl;
  }

  return self;
}

+ (id)addressBookParsedResultWithNames:(NSArray *)names pronunciation:(NSString *)pronunciation phoneNumbers:(NSArray *)phoneNumbers
                            phoneTypes:(NSArray *)phoneTypes emails:(NSArray *)emails emailTypes:(NSArray *)emailTypes
                      instantMessenger:(NSString *)instantMessenger note:(NSString *)note addresses:(NSArray *)addresses
                          addressTypes:(NSArray *)addressTypes org:(NSString *)org birthday:(NSString *)birthday
                                 title:(NSString *)title url:(NSString *)url {
  return [[[self alloc] initWithNames:names pronunciation:pronunciation phoneNumbers:phoneNumbers
                           phoneTypes:phoneTypes emails:emails emailTypes:emailTypes
                     instantMessenger:instantMessenger note:note addresses:addresses
                         addressTypes:addressTypes org:org birthday:birthday title:title url:url] autorelease];
}

- (void)dealloc {
  [names release];
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
  [ZXParsedResult maybeAppend:self.instantMessenger result:result];
  [ZXParsedResult maybeAppend:self.url result:result];
  [ZXParsedResult maybeAppend:self.birthday result:result];
  [ZXParsedResult maybeAppend:self.note result:result];
  return result;
}

@end

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
#import "ZXAddressBookParsedResultTestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXParsedResult.h"
#import "ZXResultParser.h"

@interface ZXAddressBookParsedResultTestCase ()

- (void)doTestWithContents:(NSString*)contents
                     title:(NSString*)title
                     names:(NSArray*)names
             pronunciation:(NSArray*)pronunciation
                 addresses:(NSArray*)addresses
                    emails:(NSArray*)emails
              phoneNumbers:(NSArray*)phoneNumbers
                       org:(NSString*)org
                       url:(NSString*)url
                  birthday:(NSString*)birthday
                      note:(NSString*)note;

@end

@implementation ZXAddressBookParsedResultTestCase

- (void)testAddressBookDocomo {
  [self doTestWithContents:@"MECARD:N:Sean Owen;;"
                     title:nil
                     names:[NSArray arrayWithObject:@"Sean Owen"]
             pronunciation:nil
                 addresses:nil
                    emails:nil
              phoneNumbers:nil
                       org:nil
                       url:nil
                  birthday:nil
                      note:nil];

  [self doTestWithContents:@"MECARD:NOTE:ZXing Team;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;;"
                     title:nil
                     names:[NSArray arrayWithObject:@"Sean Owen"]
             pronunciation:nil
                 addresses:nil
                    emails:[NSArray arrayWithObject:@"srowen@example.org"]
              phoneNumbers:nil
                       org:nil
                       url:@"google.com"
                  birthday:nil
                      note:@"ZXing Team"];
}

- (void)testAddressBookAU {
  [self doTestWithContents:@"MEMORY:foo\r\nNAME1:Sean\r\nTEL1:+12125551212\r\n"
                     title:nil
                     names:[NSArray arrayWithObject:@"Sean"]
             pronunciation:nil
                 addresses:nil
                    emails:nil
              phoneNumbers:[NSArray arrayWithObject:@"+12125551212"]
                       org:nil
                       url:nil
                  birthday:nil
                      note:@"foo"];
}

- (void)testVCard {
  [self doTestWithContents:@"BEGIN:VCARD\r\nADR;HOME:123 Main St\r\nVERSION:2.1\r\nN:Owen;Sean\r\nEND:VCARD"
                     title:nil
                     names:[NSArray arrayWithObject:@"Sean Owen"]
             pronunciation:nil
                 addresses:[NSArray arrayWithObject:@"123 Main St"]
                    emails:nil
              phoneNumbers:nil
                       org:nil
                       url:nil
                  birthday:nil
                      note:nil];
}

- (void)testVCardCaseInsensitive {
  [self doTestWithContents:@"begin:vcard\r\nadr;HOME:123 Main St\r\nVersion:2.1\r\nn:Owen;Sean\r\nEND:VCARD"
                     title:nil
                     names:[NSArray arrayWithObject:@"Sean Owen"]
             pronunciation:nil
                 addresses:[NSArray arrayWithObject:@"123 Main St"]
                    emails:nil
              phoneNumbers:nil
                       org:nil
                       url:nil
                  birthday:nil
                      note:nil];
}

- (void)testEscapedVCard {
  [self doTestWithContents:@"BEGIN:VCARD\r\nADR;HOME:123\\;\\\\ Main\\, St\\nHome\r\nVERSION:2.1\r\nN:Owen;Sean\r\nEND:VCARD"
                     title:nil
                     names:[NSArray arrayWithObject:@"Sean Owen"]
             pronunciation:nil
                 addresses:[NSArray arrayWithObject:@"123;\\ Main, St\nHome"]
                    emails:nil
              phoneNumbers:nil
                       org:nil
                       url:nil
                  birthday:nil
                      note:nil];
}

- (void)testBizcard {
  [self doTestWithContents:@"BIZCARD:N:Sean;X:Owen;C:Google;A:123 Main St;M:+12125551212;E:srowen@example.org;"
                     title:nil
                     names:[NSArray arrayWithObject:@"Sean Owen"]
             pronunciation:nil
                 addresses:[NSArray arrayWithObject:@"123 Main St"]
                    emails:[NSArray arrayWithObject:@"srowen@example.org"]
              phoneNumbers:[NSArray arrayWithObject:@"+12125551212"]
                       org:@"Google"
                       url:nil
                  birthday:nil
                      note:nil];
}

- (void)testSeveralAddresses {
  [self doTestWithContents:@"MECARD:N:Foo Bar;ORG:Company;TEL:5555555555;EMAIL:foo.bar@xyz.com;ADR:City, 10001;"
                           @"ADR:City, 10001;NOTE:This is the memo.;;"
                     title:nil
                     names:[NSArray arrayWithObject:@"Foo Bar"]
             pronunciation:nil
                 addresses:[NSArray arrayWithObjects:@"City, 10001", @"City, 10001", nil]
                    emails:[NSArray arrayWithObject:@"foo.bar@xyz.com"]
              phoneNumbers:[NSArray arrayWithObject:@"5555555555"]
                       org:@"Company"
                       url:nil
                  birthday:nil
                      note:@"This is the memo."];
}

- (void)testQuotedPrintable {
  [self doTestWithContents:@"BEGIN:VCARD\r\nADR;HOME;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:;;"
                           @"=38=38=20=4C=79=6E=62=72=6F=6F=6B=0D=0A=43=\r\n"
                           @"=4F=20=36=39=39=\r\n"
                           @"=39=39;;;\r\nEND:VCARD"
                     title:nil
                     names:nil
             pronunciation:nil
                 addresses:[NSArray arrayWithObject:@"88 Lynbrook\r\nCO 69999"]
                    emails:nil
              phoneNumbers:nil
                       org:nil
                       url:nil
                  birthday:nil
                      note:nil];
}

- (void)testVCardEscape {
  [self doTestWithContents:@"BEGIN:VCARD\r\nNOTE:foo\\nbar\r\nEND:VCARD"
                     title:nil
                     names:nil
             pronunciation:nil
                 addresses:nil
                    emails:nil
              phoneNumbers:nil
                       org:nil
                       url:nil
                  birthday:nil
                      note:@"foo\nbar"];
  [self doTestWithContents:@"BEGIN:VCARD\r\nNOTE:foo\\;bar\r\nEND:VCARD"
                     title:nil
                     names:nil
             pronunciation:nil
                 addresses:nil
                    emails:nil
              phoneNumbers:nil
                       org:nil
                       url:nil
                  birthday:nil
                      note:@"foo;bar"];
  [self doTestWithContents:@"BEGIN:VCARD\r\nNOTE:foo\\\\bar\r\nEND:VCARD"
                     title:nil
                     names:nil
             pronunciation:nil
                 addresses:nil
                    emails:nil
              phoneNumbers:nil
                       org:nil
                       url:nil
                  birthday:nil
                      note:@"foo\\bar"];
  [self doTestWithContents:@"BEGIN:VCARD\r\nNOTE:foo\\,bar\r\nEND:VCARD"
                     title:nil
                     names:nil
             pronunciation:nil
                 addresses:nil
                    emails:nil
              phoneNumbers:nil
                       org:nil
                       url:nil
                  birthday:nil
                      note:@"foo,bar"];
}

- (void)doTestWithContents:(NSString*)contents
                     title:(NSString*)title
                     names:(NSArray*)names
             pronunciation:(NSArray*)pronunciation
                 addresses:(NSArray*)addresses
                    emails:(NSArray*)emails
              phoneNumbers:(NSArray*)phoneNumbers
                       org:(NSString*)org
                       url:(NSString*)url
                  birthday:(NSString*)birthday
                      note:(NSString*)note {
  ZXResult* fakeResult = [ZXResult resultWithText:contents rawBytes:NULL length:0 resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(kParsedResultTypeAddressBook, result.type, @"Result type mismatch");
  ZXAddressBookParsedResult* addressResult = (ZXAddressBookParsedResult*)result;
  STAssertEqualObjects(addressResult.title, title, @"Titles do not match");
  STAssertEqualObjects(addressResult.names, names, @"Names do not match");
  STAssertEqualObjects(addressResult.pronunciation, pronunciation, @"Pronunciation does not match");
  STAssertEqualObjects(addressResult.addresses, addresses, @"Addresses do not match");
  STAssertEqualObjects(addressResult.emails, emails, @"Emails do not match");
  STAssertEqualObjects(addressResult.phoneNumbers, phoneNumbers, @"Phone numbers do not match");
  STAssertEqualObjects(addressResult.org, org, @"Org does not match");
  STAssertEqualObjects(addressResult.url, url, @"URL does not match");
  STAssertEqualObjects(addressResult.birthday, birthday, @"Birthday does not match");
  STAssertEqualObjects(addressResult.note, note, @"Note does not match");
}

@end

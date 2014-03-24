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

#import "ZXParsedReaderResultTestCase.h"

@implementation ZXParsedReaderResultTestCase

- (void)testTextType {
  [self doTestResultWithContents:@"" goldenResult:@"" type:kParsedResultTypeText];
  [self doTestResultWithContents:@"foo" goldenResult:@"foo" type:kParsedResultTypeText];
  [self doTestResultWithContents:@"Hi." goldenResult:@"Hi." type:kParsedResultTypeText];
  [self doTestResultWithContents:@"This is a test\nwith newlines" goldenResult:@"This is a test\nwith newlines"
                            type:kParsedResultTypeText];
  [self doTestResultWithContents:@"This: a test with lots of @ nearly-random punctuation! No? OK then."
                    goldenResult:@"This: a test with lots of @ nearly-random punctuation! No? OK then."
                            type:kParsedResultTypeText];
}

- (void)testBookmarkType {
  [self doTestResultWithContents:@"MEBKM:URL:google.com;;" goldenResult:@"http://google.com" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"MEBKM:URL:google.com;TITLE:Google;;" goldenResult:@"Google\nhttp://google.com"
                            type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"MEBKM:TITLE:Google;URL:google.com;;" goldenResult:@"Google\nhttp://google.com"
                            type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"MEBKM:URL:http://google.com;;" goldenResult:@"http://google.com" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"MEBKM:URL:HTTPS://google.com;;" goldenResult:@"HTTPS://google.com" type:kParsedResultTypeURI];
}

- (void)testURLTOType {
  [self doTestResultWithContents:@"urlto:foo:bar.com" goldenResult:@"foo\nhttp://bar.com" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"URLTO:foo:bar.com" goldenResult:@"foo\nhttp://bar.com" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"URLTO::bar.com" goldenResult:@"http://bar.com" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"URLTO::http://bar.com" goldenResult:@"http://bar.com" type:kParsedResultTypeURI];
}

- (void)testEmailType {
  [self doTestResultWithContents:@"MATMSG:TO:srowen@example.org;;" goldenResult:@"srowen@example.org"
                            type:kParsedResultTypeEmailAddress];
  [self doTestResultWithContents:@"MATMSG:TO:srowen@example.org;SUB:Stuff;;" goldenResult:@"srowen@example.org\nStuff"
                            type:kParsedResultTypeEmailAddress];
  [self doTestResultWithContents:@"MATMSG:TO:srowen@example.org;SUB:Stuff;BODY:This is some text;;"
                    goldenResult:@"srowen@example.org\nStuff\nThis is some text" type:kParsedResultTypeEmailAddress];
  [self doTestResultWithContents:@"MATMSG:SUB:Stuff;BODY:This is some text;TO:srowen@example.org;;"
                    goldenResult:@"srowen@example.org\nStuff\nThis is some text" type:kParsedResultTypeEmailAddress];
  [self doTestResultWithContents:@"TO:srowen@example.org;SUB:Stuff;BODY:This is some text;;"
                    goldenResult:@"TO:srowen@example.org;SUB:Stuff;BODY:This is some text;;" type:kParsedResultTypeText];
}

- (void)testEmailAddressType {
  [self doTestResultWithContents:@"srowen@example.org" goldenResult:@"srowen@example.org" type:kParsedResultTypeEmailAddress];
  [self doTestResultWithContents:@"mailto:srowen@example.org" goldenResult:@"srowen@example.org" type:kParsedResultTypeEmailAddress];
  [self doTestResultWithContents:@"MAILTO:srowen@example.org" goldenResult:@"srowen@example.org" type:kParsedResultTypeEmailAddress];
  [self doTestResultWithContents:@"srowen@example" goldenResult:@"srowen@example" type:kParsedResultTypeEmailAddress];
  [self doTestResultWithContents:@"srowen" goldenResult:@"srowen" type:kParsedResultTypeText];
  [self doTestResultWithContents:@"Let's meet @ 2" goldenResult:@"Let's meet @ 2" type:kParsedResultTypeText];
}

- (void)testAddressBookType {
  [self doTestResultWithContents:@"MECARD:N:Sean Owen;;" goldenResult:@"Sean Owen" type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"MECARD:TEL:+12125551212;N:Sean Owen;;" goldenResult:@"Sean Owen\n+12125551212"
                            type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"MECARD:TEL:+12125551212;N:Sean Owen;URL:google.com;;"
                    goldenResult:@"Sean Owen\n+12125551212\ngoogle.com" type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"MECARD:TEL:+12125551212;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;"
                    goldenResult:@"Sean Owen\n+12125551212\nsrowen@example.org\ngoogle.com" type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"MECARD:ADR:76 9th Ave;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;"
                    goldenResult:@"Sean Owen\n76 9th Ave\nsrowen@example.org\ngoogle.com" type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"MECARD:BDAY:19760520;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;"
                    goldenResult:@"Sean Owen\nsrowen@example.org\ngoogle.com\n19760520" type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"MECARD:ORG:Google;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;"
                    goldenResult:@"Sean Owen\nGoogle\nsrowen@example.org\ngoogle.com" type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"MECARD:NOTE:ZXing Team;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;"
                    goldenResult:@"Sean Owen\nsrowen@example.org\ngoogle.com\nZXing Team" type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"N:Sean Owen;TEL:+12125551212;;" goldenResult:@"N:Sean Owen;TEL:+12125551212;;"
                            type:kParsedResultTypeText];
}

- (void)testAddressBookAUType {
  [self doTestResultWithContents:@"MEMORY:\r\n" goldenResult:@"" type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"MEMORY:foo\r\nNAME1:Sean\r\n" goldenResult:@"Sean\nfoo" type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"TEL1:+12125551212\r\nMEMORY:\r\n" goldenResult:@"+12125551212" type:kParsedResultTypeAddressBook];
}

- (void)testBizcard {
  [self doTestResultWithContents:@"BIZCARD:N:Sean;X:Owen;C:Google;A:123 Main St;M:+12225551212;E:srowen@example.org;"
                    goldenResult:@"Sean Owen\nGoogle\n123 Main St\n+12225551212\nsrowen@example.org"
                            type:kParsedResultTypeAddressBook];
}

- (void)testUPCA {
  [self doTestResultWithContents:@"123456789012" goldenResult:@"123456789012" type:kParsedResultTypeProduct format:kBarcodeFormatUPCA];
  [self doTestResultWithContents:@"1234567890123" goldenResult:@"1234567890123" type:kParsedResultTypeProduct format:kBarcodeFormatUPCA];
  [self doTestResultWithContents:@"12345678901" goldenResult:@"12345678901" type:kParsedResultTypeText];
}

- (void)testUPCE {
  [self doTestResultWithContents:@"01234565" goldenResult:@"01234565" type:kParsedResultTypeProduct format:kBarcodeFormatUPCE];
}

- (void)testEAN {
  [self doTestResultWithContents:@"00393157" goldenResult:@"00393157" type:kParsedResultTypeProduct format:kBarcodeFormatEan8];
  [self doTestResultWithContents:@"00393158" goldenResult:@"00393158" type:kParsedResultTypeText];
  [self doTestResultWithContents:@"5051140178499" goldenResult:@"5051140178499" type:kParsedResultTypeProduct format:kBarcodeFormatEan13];
  [self doTestResultWithContents:@"5051140178490" goldenResult:@"5051140178490" type:kParsedResultTypeText];
}

- (void)testISBN {
  [self doTestResultWithContents:@"9784567890123" goldenResult:@"9784567890123" type:kParsedResultTypeISBN format:kBarcodeFormatEan13];
  [self doTestResultWithContents:@"9794567890123" goldenResult:@"9794567890123" type:kParsedResultTypeISBN format:kBarcodeFormatEan13];
  [self doTestResultWithContents:@"97845678901" goldenResult:@"97845678901" type:kParsedResultTypeText];
  [self doTestResultWithContents:@"97945678901" goldenResult:@"97945678901" type:kParsedResultTypeText];
}

- (void)testURI {
  [self doTestResultWithContents:@"http://google.com" goldenResult:@"http://google.com" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"google.com" goldenResult:@"http://google.com" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"https://google.com" goldenResult:@"https://google.com" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"HTTP://google.com" goldenResult:@"HTTP://google.com" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"http://google.com/foobar" goldenResult:@"http://google.com/foobar" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"https://google.com:443/foobar" goldenResult:@"https://google.com:443/foobar" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"google.com:443" goldenResult:@"http://google.com:443" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"google.com:443/" goldenResult:@"http://google.com:443/" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"google.com:443/foobar" goldenResult:@"http://google.com:443/foobar" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"http://google.com:443/foobar" goldenResult:@"http://google.com:443/foobar" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"https://google.com:443/foobar" goldenResult:@"https://google.com:443/foobar" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"ftp://google.com/fake" goldenResult:@"ftp://google.com/fake" type:kParsedResultTypeURI];
  [self doTestResultWithContents:@"gopher://google.com/obsolete" goldenResult:@"gopher://google.com/obsolete" type:kParsedResultTypeURI];
}

- (void)testGeo {
  [self doTestResultWithContents:@"geo:1,2" goldenResult:@"1.000000, 2.000000" type:kParsedResultTypeGeo];
  [self doTestResultWithContents:@"geo:1,2,3" goldenResult:@"1.000000, 2.000000, 3.000000m" type:kParsedResultTypeGeo];
  [self doTestResultWithContents:@"geo:80.33,-32.3344,3.35" goldenResult:@"80.330000, -32.334400, 3.350000m" type:kParsedResultTypeGeo];
  [self doTestResultWithContents:@"geo" goldenResult:@"geo" type:kParsedResultTypeText];
  [self doTestResultWithContents:@"geography" goldenResult:@"geography" type:kParsedResultTypeText];
}

- (void)testTel {
  [self doTestResultWithContents:@"tel:+15551212" goldenResult:@"+15551212" type:kParsedResultTypeTel];
  [self doTestResultWithContents:@"TEL:+15551212" goldenResult:@"+15551212" type:kParsedResultTypeTel];
  [self doTestResultWithContents:@"tel:212 555 1212" goldenResult:@"212 555 1212" type:kParsedResultTypeTel];
  [self doTestResultWithContents:@"tel:2125551212" goldenResult:@"2125551212" type:kParsedResultTypeTel];
  [self doTestResultWithContents:@"tel:212-555-1212" goldenResult:@"212-555-1212" type:kParsedResultTypeTel];
  [self doTestResultWithContents:@"tel" goldenResult:@"tel" type:kParsedResultTypeText];
  [self doTestResultWithContents:@"telephone" goldenResult:@"telephone" type:kParsedResultTypeText];
}

- (void)testVCard {
  [self doTestResultWithContents:@"BEGIN:VCARD\r\nEND:VCARD" goldenResult:@"" type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"BEGIN:VCARD\r\nN:Owen;Sean\r\nEND:VCARD" goldenResult:@"Sean Owen"
                            type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"BEGIN:VCARD\r\nVERSION:2.1\r\nN:Owen;Sean\r\nEND:VCARD" goldenResult:@"Sean Owen"
                            type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"BEGIN:VCARD\r\nADR;HOME:123 Main St\r\nVERSION:2.1\r\nN:Owen;Sean\r\nEND:VCARD"
                    goldenResult:@"Sean Owen\n123 Main St" type:kParsedResultTypeAddressBook];
  [self doTestResultWithContents:@"BEGIN:VCARD" goldenResult:@"" type:kParsedResultTypeAddressBook];
}

- (void)testVEvent {
  // UTC times
  [self doTestResultWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504T123456Z\r\n"
                                 @"DTEND:20080505T234555Z\r\nEND:VEVENT\r\nEND:VCALENDAR"
                    goldenResult:@"foo\nMay 4, 2008 12:34:56 PM\nMay 5, 2008 11:45:55 PM"
                            type:kParsedResultTypeCalendar];
  [self doTestResultWithContents:@"BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504T123456Z\r\n"
                                 @"DTEND:20080505T234555Z\r\nEND:VEVENT"
                    goldenResult:@"foo\nMay 4, 2008 12:34:56 PM\nMay 5, 2008 11:45:55 PM"
                            type:kParsedResultTypeCalendar];
  // Local times
  [self doTestResultWithContents:@"BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504T123456\r\n"
                                 @"DTEND:20080505T234555\r\nEND:VEVENT"
                    goldenResult:@"foo\nMay 4, 2008 12:34:56 PM\nMay 5, 2008 11:45:55 PM"
                            type:kParsedResultTypeCalendar];
  // Date only (all day event)
  [self doTestResultWithContents:@"BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504\r\n"
                                 @"DTEND:20080505\r\nEND:VEVENT"
                    goldenResult:@"foo\nMay 4, 2008\nMay 5, 2008"
                            type:kParsedResultTypeCalendar];
  // Start time only
  [self doTestResultWithContents:@"BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504T123456Z\r\nEND:VEVENT"
                    goldenResult:@"foo\nMay 4, 2008 12:34:56 PM" type:kParsedResultTypeCalendar];
  [self doTestResultWithContents:@"BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504T123456\r\nEND:VEVENT"
                    goldenResult:@"foo\nMay 4, 2008 12:34:56 PM" type:kParsedResultTypeCalendar];
  [self doTestResultWithContents:@"BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504\r\nEND:VEVENT"
                    goldenResult:@"foo\nMay 4, 2008" type:kParsedResultTypeCalendar];
  [self doTestResultWithContents:@"BEGIN:VEVENT\r\nDTEND:20080505T\r\nEND:VEVENT"
                    goldenResult:@"BEGIN:VEVENT\r\nDTEND:20080505T\r\nEND:VEVENT" type:kParsedResultTypeURI];
  // Yeah, it's OK that this is thought of as maybe a URI as long as it's not CALENDAR
  // Make sure illegal entries without newlines don't crash
  [self doTestResultWithContents:@"BEGIN:VEVENTSUMMARY:EventDTSTART:20081030T122030ZDTEND:20081030T132030ZEND:VEVENT"
                    goldenResult:@"BEGIN:VEVENTSUMMARY:EventDTSTART:20081030T122030ZDTEND:20081030T132030ZEND:VEVENT"
                            type:kParsedResultTypeURI];
}

- (void)testSMS {
  [self doTestResultWithContents:@"sms:+15551212" goldenResult:@"+15551212" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"SMS:+15551212" goldenResult:@"+15551212" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"sms:+15551212;via=999333" goldenResult:@"+15551212" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"sms:+15551212?subject=foo&body=bar" goldenResult:@"+15551212\nfoo\nbar" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"sms:+15551212,+12124440101" goldenResult:@"+15551212\n+12124440101" type:kParsedResultTypeSMS];
}

- (void)testSMSTO {
  [self doTestResultWithContents:@"SMSTO:+15551212" goldenResult:@"+15551212" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"smsto:+15551212" goldenResult:@"+15551212" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"smsto:+15551212:subject" goldenResult:@"+15551212\nsubject" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"smsto:+15551212:My message" goldenResult:@"+15551212\nMy message" type:kParsedResultTypeSMS];
  // Need to handle question mark in the subject
  [self doTestResultWithContents:@"smsto:+15551212:What's up?" goldenResult:@"+15551212\nWhat's up?" type:kParsedResultTypeSMS];
  // Need to handle colon in the subject
  [self doTestResultWithContents:@"smsto:+15551212:Directions: Do this"
                    goldenResult:@"+15551212\nDirections: Do this" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"smsto:212-555-1212:Here's a longer message. Should be fine."
                    goldenResult:@"212-555-1212\nHere's a longer message. Should be fine." type:kParsedResultTypeSMS];
}

- (void)testMMS {
  [self doTestResultWithContents:@"mms:+15551212" goldenResult:@"+15551212" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"MMS:+15551212" goldenResult:@"+15551212" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"mms:+15551212;via=999333" goldenResult:@"+15551212" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"mms:+15551212?subject=foo&body=bar" goldenResult:@"+15551212\nfoo\nbar" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"mms:+15551212,+12124440101" goldenResult:@"+15551212\n+12124440101" type:kParsedResultTypeSMS];
}

- (void)testMMSTO {
  [self doTestResultWithContents:@"MMSTO:+15551212" goldenResult:@"+15551212" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"mmsto:+15551212" goldenResult:@"+15551212" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"mmsto:+15551212:subject" goldenResult:@"+15551212\nsubject" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"mmsto:+15551212:My message" goldenResult:@"+15551212\nMy message" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"mmsto:+15551212:What's up?" goldenResult:@"+15551212\nWhat's up?" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"mmsto:+15551212:Directions: Do this"
                    goldenResult:@"+15551212\nDirections: Do this" type:kParsedResultTypeSMS];
  [self doTestResultWithContents:@"mmsto:212-555-1212:Here's a longer message. Should be fine."
                    goldenResult:@"212-555-1212\nHere's a longer message. Should be fine." type:kParsedResultTypeSMS];
}

- (void)doTestResultWithContents:(NSString *)contents
                    goldenResult:(NSString *)goldenResult
                            type:(ZXParsedResultType)type {
  [self doTestResultWithContents:contents goldenResult:goldenResult type:type format:kBarcodeFormatQRCode]; // QR code is arbitrary
}

- (void)doTestResultWithContents:(NSString *)contents
                    goldenResult:(NSString *)goldenResult
                            type:(ZXParsedResultType)type
                          format:(ZXBarcodeFormat)format {
  ZXResult *fakeResult = [ZXResult resultWithText:contents rawBytes:nil resultPoints:nil format:format];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];
  XCTAssertNotNil(result);
  XCTAssertEqual(type, result.type);

  NSString *displayResult = result.displayResult;
  XCTAssertEqualObjects(goldenResult, displayResult);
}

@end

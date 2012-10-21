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

#import "ZXResultParser.h"
#import "ZXURIParsedResult.h"
#import "ZXURIParsedResultTestCase.h"

@interface ZXURIParsedResultTestCase ()

- (void)doTestWithContents:(NSString*)contents uri:(NSString*)uri title:(NSString*)title;
- (void)doTestNotUri:(NSString*)text;
- (void)doTestIsPossiblyMalicious:(NSString*)uri expected:(BOOL)expected;

@end

@implementation ZXURIParsedResultTestCase

- (void)testBookmarkDocomo {
  [self doTestWithContents:@"MEBKM:URL:google.com;;" uri:@"http://google.com" title:nil];
  [self doTestWithContents:@"MEBKM:URL:http://google.com;;" uri:@"http://google.com" title:nil];
  [self doTestWithContents:@"MEBKM:URL:google.com;TITLE:Google;" uri:@"http://google.com" title:@"Google"];
}

- (void)testURI {
  [self doTestWithContents:@"google.com" uri:@"http://google.com" title:nil];
  [self doTestWithContents:@"http://google.com" uri:@"http://google.com" title:nil];
  [self doTestWithContents:@"https://google.com" uri:@"https://google.com" title:nil];
  [self doTestWithContents:@"google.com:443" uri:@"http://google.com:443" title:nil];
  [self doTestWithContents:@"https://www.google.com/calendar/hosted/google.com/embed?mode=AGENDA&force_login=true&src=google.com_726f6f6d5f6265707075@resource.calendar.google.com"
                       uri:@"https://www.google.com/calendar/hosted/google.com/embed?mode=AGENDA&force_login=true&src=google.com_726f6f6d5f6265707075@resource.calendar.google.com"
                     title:nil];
  [self doTestWithContents:@"otpauth://remoteaccess?devaddr=00%a1b2%c3d4&devname=foo&key=bar"
                       uri:@"otpauth://remoteaccess?devaddr=00%a1b2%c3d4&devname=foo&key=bar"
                     title:nil];
  [self doTestWithContents:@"s3://amazon.com:8123" uri:@"s3://amazon.com:8123" title:nil];
  [self doTestWithContents:@"HTTP://R.BEETAGG.COM/?12345" uri:@"http://R.BEETAGG.COM/?12345" title:nil];
}

- (void)testNotURI {
  [self doTestNotUri:@"google.c"];
  [self doTestNotUri:@".com"];
  [self doTestNotUri:@":80/"];
  [self doTestNotUri:@"ABC,20.3,AB,AD"];
}

- (void)testURLTO {
  [self doTestWithContents:@"urlto::bar.com" uri:@"http://bar.com" title:nil];
  [self doTestWithContents:@"urlto::http://bar.com" uri:@"http://bar.com" title:nil];
  [self doTestWithContents:@"urlto:foo:bar.com" uri:@"http://bar.com" title:@"foo"];
}

- (void)testGarbage {
  [self doTestNotUri:@"Da65cV1g^>%^f0bAbPn1CJB6lV7ZY8hs0Sm:DXU0cd]GyEeWBz8]bUHLB"];
  [self doTestNotUri:[NSString stringWithFormat:@"DEA%C%CM%C%C\b√•%C¬áHO%CX$%C%C%Cwfc%C!√æ¬ì¬ò%C%C¬æZ{√π√é√ù√ö¬óZ¬ß¬®+y_zb√±k%C¬∏%C¬Ü√ú%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C%C¬£.ux",
                      (unichar)0x0003, (unichar)0x0019, (unichar)0x0006, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0001,
                      (unichar)0x0000, (unichar)0x001F, (unichar)0x0007, (unichar)0x0013, (unichar)0x0013, (unichar)0x00117, (unichar)0x000E,
                      (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000,
                      (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000,
                      (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000,
                      (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000, (unichar)0x0000]];
}

- (void)testIsPossiblyMalicious {
  [self doTestIsPossiblyMalicious:@"http://google.com" expected:NO];
  [self doTestIsPossiblyMalicious:@"http://google.com@evil.com" expected:YES];
  [self doTestIsPossiblyMalicious:@"http://google.com:@evil.com" expected:YES];
  [self doTestIsPossiblyMalicious:@"google.com:@evil.com" expected:NO];
  [self doTestIsPossiblyMalicious:@"https://google.com:443" expected:NO];
  [self doTestIsPossiblyMalicious:@"https://google.com:443/" expected:NO];
  [self doTestIsPossiblyMalicious:@"https://evil@google.com:443" expected:YES];
  [self doTestIsPossiblyMalicious:@"http://google.com/foo@bar" expected:NO];
  [self doTestIsPossiblyMalicious:@"http://google.com/@@" expected:NO];
}

- (void)testExotic {
  [self doTestWithContents:@"bitcoin:mySD89iqpmptrK3PhHFW9fa7BXiP7ANy3Y"
                       uri:@"bitcoin:mySD89iqpmptrK3PhHFW9fa7BXiP7ANy3Y"
                     title:nil];
}

- (void)doTestWithContents:(NSString*)contents uri:(NSString*)uri title:(NSString*)title {
  ZXResult* fakeResult = [ZXResult resultWithText:contents rawBytes:NULL length:0 resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeURI, @"Types don't match");
  ZXURIParsedResult* uriResult = (ZXURIParsedResult*)result;
  STAssertEqualObjects(uriResult.uri, uri, @"URIs don't match");
  STAssertEqualObjects(uriResult.title, title, @"Titles don't match");
}

- (void)doTestNotUri:(NSString*)text {
  ZXResult* fakeResult = [ZXResult resultWithText:text rawBytes:NULL length:0 resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeText, @"Types don't match");
  STAssertEqualObjects(result.displayResult, text, @"Display result doesn't match");
}

- (void)doTestIsPossiblyMalicious:(NSString*)uri expected:(BOOL)expected {
  ZXURIParsedResult* result = [ZXURIParsedResult uriParsedResultWithUri:uri title:nil];
  STAssertEquals([result possiblyMaliciousURI], expected,
                 expected ? @"Expected to be possibly malicious URI but wasn't" : @"Not expected to be possibly malicious URI but was");
}

@end

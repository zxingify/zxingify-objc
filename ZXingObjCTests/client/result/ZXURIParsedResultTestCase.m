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

#import "ZXURIParsedResultTestCase.h"

@implementation ZXURIParsedResultTestCase

- (void)testBookmarkDocomo {
  [self doTestWithContents:@"MEBKM:URL:google.com;;" uri:@"http://google.com" title:nil];
  [self doTestWithContents:@"MEBKM:URL:http://google.com;;" uri:@"http://google.com" title:nil];
  [self doTestWithContents:@"MEBKM:URL:google.com;TITLE:Google;" uri:@"http://google.com" title:@"Google"];
}

- (void)testURI {
  [self doTestWithContents:@"google.com" uri:@"http://google.com" title:nil];
  [self doTestWithContents:@"123.com" uri:@"http://123.com" title:nil];
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
  [self doTestWithContents:@"HTTP://R.BEETAGG.COM/?12345" uri:@"HTTP://R.BEETAGG.COM/?12345" title:nil];
}

- (void)testNotURI {
  [self doTestNotUri:@"google.c"];
  [self doTestNotUri:@".com"];
  [self doTestNotUri:@":80/"];
  [self doTestNotUri:@"ABC,20.3,AB,AD"];
  [self doTestNotUri:@"http://google.com?q=foo bar"];
  [self doTestNotUri:@"12756.501"];
  [self doTestNotUri:@"google.50"];
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
  [self doTestWithContents:@"BTCTX:-TC4TO3$ZYZTC5NC83/SYOV+YGUGK:$BSF0P8/STNTKTKS.V84+JSA$LB+EHCG+8A725.2AZ-NAVX3VBV5K4MH7UL2.2M:"
   "F*M9HSL*$2P7T*FX.ZT80GWDRV0QZBPQ+O37WDCNZBRM3EQ0S9SZP+3BPYZG02U/LA*89C2U.V1TS.CT1VF3DIN*HN3W-O-"
   "0ZAKOAB32/.8:J501GJJTTWOA+5/6$MIYBERPZ41NJ6-WSG/*Z48ZH*LSAOEM*IXP81L:$F*W08Z60CR*C*P.JEEVI1F02J07L6+"
   "W4L1G$/IC*$16GK6A+:I1-:LJ:Z-P3NW6Z6ADFB-F2AKE$2DWN23GYCYEWX9S8L+LF$VXEKH7/R48E32PU+A:9H:8O5"
                       uri:@"BTCTX:-TC4TO3$ZYZTC5NC83/SYOV+YGUGK:$BSF0P8/STNTKTKS.V84+JSA$LB+EHCG+8A725.2AZ-NAVX3VBV5K4MH7UL2.2M:"
   "F*M9HSL*$2P7T*FX.ZT80GWDRV0QZBPQ+O37WDCNZBRM3EQ0S9SZP+3BPYZG02U/LA*89C2U.V1TS.CT1VF3DIN*HN3W-O-"
   "0ZAKOAB32/.8:J501GJJTTWOA+5/6$MIYBERPZ41NJ6-WSG/*Z48ZH*LSAOEM*IXP81L:$F*W08Z60CR*C*P.JEEVI1F02J07L6+"
   "W4L1G$/IC*$16GK6A+:I1-:LJ:Z-P3NW6Z6ADFB-F2AKE$2DWN23GYCYEWX9S8L+LF$VXEKH7/R48E32PU+A:9H:8O5"
                     title:nil];
}

- (void)doTestWithContents:(NSString *)contents uri:(NSString *)uri title:(NSString *)title {
  ZXResult *fakeResult = [ZXResult resultWithText:contents rawBytes:nil resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];
  XCTAssertEqual(result.type, kParsedResultTypeURI, @"Types don't match");
  ZXURIParsedResult *uriResult = (ZXURIParsedResult *)result;
  XCTAssertEqualObjects(uriResult.uri, uri, @"URIs don't match");
  XCTAssertEqualObjects(uriResult.title, title, @"Titles don't match");
}

- (void)doTestNotUri:(NSString *)text {
  ZXResult *fakeResult = [ZXResult resultWithText:text rawBytes:nil resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];
  XCTAssertEqual(result.type, kParsedResultTypeText, @"Types don't match");
  XCTAssertEqualObjects(result.displayResult, text, @"Display result doesn't match");
}

- (void)doTestIsPossiblyMalicious:(NSString *)uri expected:(BOOL)expected {
  ZXURIParsedResult *result = [ZXURIParsedResult uriParsedResultWithUri:uri title:nil];
  XCTAssertEqual([result possiblyMaliciousURI], expected, @"%@",
                 expected ? @"Expected to be possibly malicious URI but wasn't" : @"Not expected to be possibly malicious URI but was");
}

@end

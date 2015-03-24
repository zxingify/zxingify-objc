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

#import "ZXEmailAddressParsedResultTestCase.h"

@implementation ZXEmailAddressParsedResultTestCase

- (void)testEmailAddress {
  [self doTestWithContents:@"srowen@example.org" to:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"mailto:srowen@example.org" to:@"srowen@example.org" subject:nil body:nil];
}

- (void)testTos {
  [self doTestWithContents:@"mailto:srowen@example.org,bob@example.org"
                       tos:@[@"srowen@example.org", @"bob@example.org"]
                       ccs:nil bccs:nil subject:nil body:nil];
  [self doTestWithContents:@"mailto:?to=srowen@example.org,bob@example.org"
                       tos:@[@"srowen@example.org", @"bob@example.org"]
                       ccs:nil bccs:nil subject:nil body:nil];
}

- (void)testCCs {
  [self doTestWithContents:@"mailto:?cc=srowen@example.org"
                       tos:nil
                       ccs:@[@"srowen@example.org"]
                      bccs:nil subject:nil body:nil];
  [self doTestWithContents:@"mailto:?cc=srowen@example.org,bob@example.org"
                       tos:nil
                       ccs:@[@"srowen@example.org", @"bob@example.org"]
                      bccs:nil subject:nil body:nil];
}

- (void)testBCCs {
  [self doTestWithContents:@"mailto:?bcc=srowen@example.org"
                       tos:nil ccs:nil
                      bccs:@[@"srowen@example.org"]
                   subject:nil body:nil];
  [self doTestWithContents:@"mailto:?bcc=srowen@example.org,bob@example.org"
                       tos:nil ccs:nil
                      bccs:@[@"srowen@example.org", @"bob@example.org"]
                   subject:nil body:nil];
}

- (void)testAll {
  [self doTestWithContents:@"mailto:bob@example.org?cc=foo@example.org&bcc=srowen@example.org&subject=baz&body=buzz"
                       tos:@[@"bob@example.org"]
                       ccs:@[@"foo@example.org"]
                      bccs:@[@"srowen@example.org"]
                   subject:@"baz"
                      body:@"buzz"];
}

- (void)testEmailDocomo {
  [self doTestWithContents:@"MATMSG:TO:srowen@example.org;;" to:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"MATMSG:TO:srowen@example.org;SUB:Stuff;;" to:@"srowen@example.org" subject:@"Stuff" body:nil];
  [self doTestWithContents:@"MATMSG:TO:srowen@example.org;SUB:Stuff;BODY:This is some text;;"
                     to:@"srowen@example.org" subject:@"Stuff" body:@"This is some text"];
}

- (void)testSMTP {
  [self doTestWithContents:@"smtp:srowen@example.org" to:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"SMTP:srowen@example.org" to:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"SMTP:srowen@example.org:foo" to:@"srowen@example.org" subject:@"foo" body:nil];
  [self doTestWithContents:@"SMTP:srowen@example.org:foo:bar" to:@"srowen@example.org" subject:@"foo" body:@"bar"];
}

- (void)doTestWithContents:(NSString *)contents
                        to:(NSString *)to
                   subject:(NSString *)subject
                      body:(NSString *)body {
  [self doTestWithContents:contents tos:@[to] ccs:nil bccs:nil subject:subject body:body];
}

- (void)doTestWithContents:(NSString *)contents
                       tos:(NSArray *)tos
                       ccs:(NSArray *)ccs
                      bccs:(NSArray *)bccs
                   subject:(NSString *)subject
                      body:(NSString *)body {
  ZXResult *fakeResult = [ZXResult resultWithText:contents rawBytes:nil resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];
  XCTAssertEqual(kParsedResultTypeEmailAddress, result.type, );
  ZXEmailAddressParsedResult *emailResult = (ZXEmailAddressParsedResult *)result;
  XCTAssertEqualObjects(tos, emailResult.tos);
  XCTAssertEqualObjects(ccs, emailResult.ccs);
  XCTAssertEqualObjects(bccs, emailResult.bccs);
  XCTAssertEqualObjects(subject, emailResult.subject);
  XCTAssertEqualObjects(body, emailResult.body);
}

@end

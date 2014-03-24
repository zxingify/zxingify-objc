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
  [self doTestWithContents:@"srowen@example.org" email:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"mailto:srowen@example.org" email:@"srowen@example.org" subject:nil body:nil];
}

- (void)testEmailDocomo {
  [self doTestWithContents:@"MATMSG:TO:srowen@example.org;;" email:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"MATMSG:TO:srowen@example.org;SUB:Stuff;;" email:@"srowen@example.org" subject:@"Stuff" body:nil];
  [self doTestWithContents:@"MATMSG:TO:srowen@example.org;SUB:Stuff;BODY:This is some text;;"
                     email:@"srowen@example.org" subject:@"Stuff" body:@"This is some text"];
}

- (void)testSMTP {
  [self doTestWithContents:@"smtp:srowen@example.org" email:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"SMTP:srowen@example.org" email:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"SMTP:srowen@example.org:foo" email:@"srowen@example.org" subject:@"foo" body:nil];
  [self doTestWithContents:@"SMTP:srowen@example.org:foo:bar" email:@"srowen@example.org" subject:@"foo" body:@"bar"];
}

- (void)doTestWithContents:(NSString *)contents
                     email:(NSString *)email
                   subject:(NSString *)subject
                      body:(NSString *)body {
  ZXResult *fakeResult = [ZXResult resultWithText:contents rawBytes:nil resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];
  XCTAssertEqual(kParsedResultTypeEmailAddress, result.type, );
  ZXEmailAddressParsedResult *emailResult = (ZXEmailAddressParsedResult *)result;
  XCTAssertEqualObjects(email, emailResult.emailAddress);
  XCTAssertEqualObjects([@"mailto:" stringByAppendingString:emailResult.emailAddress], emailResult.mailtoURI);
  XCTAssertEqualObjects(subject, emailResult.subject);
  XCTAssertEqualObjects(body, emailResult.body);
}

@end

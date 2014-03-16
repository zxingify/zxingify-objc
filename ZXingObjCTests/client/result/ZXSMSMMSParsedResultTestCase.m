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

#import "ZXSMSMMSParsedResultTestCase.h"

@implementation ZXSMSMMSParsedResultTestCase

- (void)testSMS {
  [self doTestWithContents:@"sms:+15551212" number:@"+15551212" subject:nil body:nil via:nil];
  [self doTestWithContents:@"sms:+15551212?subject=foo&body=bar" number:@"+15551212" subject:@"foo" body:@"bar" via:nil];
  [self doTestWithContents:@"sms:+15551212;via=999333" number:@"+15551212" subject:nil body:nil via:@"999333"];
}

- (void)testMMS {
  [self doTestWithContents:@"mms:+15551212" number:@"+15551212" subject:nil body:nil via:nil];
  [self doTestWithContents:@"mms:+15551212?subject=foo&body=bar" number:@"+15551212" subject:@"foo" body:@"bar" via:nil];
  [self doTestWithContents:@"mms:+15551212;via=999333" number:@"+15551212" subject:nil body:nil via:@"999333"];
}

- (void)doTestWithContents:(NSString *)contents
                    number:(NSString *)number
                   subject:(NSString *)subject
                      body:(NSString *)body
                       via:(NSString *)via {
  [self doTestWithContents:contents
                   numbers:@[number ? number : [NSNull null]]
                   subject:subject
                      body:body
                      vias:@[via ? via : [NSNull null]]];
}

- (void)doTestWithContents:(NSString *)contents
                   numbers:(NSArray *)numbers
                   subject:(NSString *)subject
                      body:(NSString *)body
                      vias:(NSArray *)vias {
  ZXResult *fakeResult = [ZXResult resultWithText:contents rawBytes:nil resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];
  XCTAssertEqual(result.type, kParsedResultTypeSMS, @"Types don't match");
  ZXSMSParsedResult *smsResult = (ZXSMSParsedResult *)result;
  XCTAssertEqualObjects(smsResult.numbers, numbers, @"Numbers don't match");
  XCTAssertEqualObjects(smsResult.subject, subject, @"Subjects don't match");
  XCTAssertEqualObjects(smsResult.body, body, @"Bodies don't match");
  XCTAssertEqualObjects(smsResult.vias, vias, @"Vias don't match");
}

@end

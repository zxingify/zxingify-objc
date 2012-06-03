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
#import "ZXSMSParsedResult.h"
#import "ZXSMSMMSParsedResultTestCase.h"

@interface ZXSMSMMSParsedResultTestCase ()

- (void)doTestWithContents:(NSString*)contents
                    number:(NSString*)number
                   subject:(NSString*)subject
                      body:(NSString*)body
                       via:(NSString*)via;

- (void)doTestWithContents:(NSString*)contents
                   numbers:(NSArray*)numbers
                   subject:(NSString*)subject
                      body:(NSString*)body
                      vias:(NSArray*)vias;

@end

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

- (void)doTestWithContents:(NSString*)contents
                    number:(NSString*)number
                   subject:(NSString*)subject
                      body:(NSString*)body
                       via:(NSString*)via {
  [self doTestWithContents:contents
                   numbers:[NSArray arrayWithObject:number ? number : [NSNull null]]
                   subject:subject
                      body:body
                      vias:[NSArray arrayWithObject:via ? via : [NSNull null]]];
}

- (void)doTestWithContents:(NSString*)contents
                   numbers:(NSArray*)numbers
                   subject:(NSString*)subject
                      body:(NSString*)body
                      vias:(NSArray*)vias {
  ZXResult* fakeResult = [ZXResult resultWithText:contents rawBytes:NULL length:0 resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeSMS, @"Types don't match");
  ZXSMSParsedResult* smsResult = (ZXSMSParsedResult*)result;
  STAssertEqualObjects(smsResult.numbers, numbers, @"Numbers don't match");
  STAssertEqualObjects(smsResult.subject, subject, @"Subjects don't match");
  STAssertEqualObjects(smsResult.body, body, @"Bodies don't match");
  STAssertEqualObjects(smsResult.vias, vias, @"Vias don't match");
}

@end

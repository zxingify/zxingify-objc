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

#import "ZXTelParsedResultTestCase.h"

@implementation ZXTelParsedResultTestCase

- (void)testTel {
  [self doTestWithContents:@"tel:+15551212" number:@"+15551212" title:nil];
  [self doTestWithContents:@"tel:2125551212" number:@"2125551212" title:nil];
}

- (void)doTestWithContents:(NSString *)contents number:(NSString *)number title:(NSString *)title {
  ZXResult *fakeResult = [ZXResult resultWithText:contents rawBytes:nil resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];
  XCTAssertEqual(result.type, kParsedResultTypeTel, @"Types don't match");
  ZXTelParsedResult *telResult = (ZXTelParsedResult *)result;
  XCTAssertEqualObjects(telResult.number, number, @"Numbers don't match");
  XCTAssertEqualObjects(telResult.title, title, @"Titles don't match");
  XCTAssertEqualObjects(telResult.telURI, [@"tel:" stringByAppendingString:number], @"Tel URIs don't match");
}

@end

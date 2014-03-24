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

#import "ZXExpandedProductParsedResultTestCase.h"

@implementation ZXExpandedProductParsedResultTestCase

- (void)test_RSSExpanded {
  NSDictionary *uncommonAIs = @{@"123": @"544654"};
  ZXResult *result = [ZXResult resultWithText:@"(01)66546(13)001205(3932)4455(3102)6544(123)544654"
                                     rawBytes:nil
                                 resultPoints:nil
                                       format:kBarcodeFormatRSSExpanded];
  ZXExpandedProductParsedResult *o = (ZXExpandedProductParsedResult *)[[[ZXExpandedProductResultParser alloc] init] parse:result];
  XCTAssertNotNil(o);
  XCTAssertEqualObjects(@"66546", o.productID);
  XCTAssertNil(o.sscc);
  XCTAssertNil(o.lotNumber);
  XCTAssertNil(o.productionDate);
  XCTAssertEqualObjects(@"001205", o.packagingDate);
  XCTAssertNil(o.bestBeforeDate);
  XCTAssertNil(o.expirationDate);
  XCTAssertEqualObjects(@"6544", o.weight);
  XCTAssertEqualObjects(@"KG", o.weightType);
  XCTAssertEqualObjects(@"2", o.weightIncrement);
  XCTAssertEqualObjects(@"5", o.price);
  XCTAssertEqualObjects(@"2", o.priceIncrement);
  XCTAssertEqualObjects(@"445", o.priceCurrency);
  XCTAssertEqualObjects(uncommonAIs, o.uncommonAIs);
}

@end

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
  XCTAssertNotNil(o, @"Expected result to be non-nil");
  XCTAssertEqualObjects(o.productID, @"66546", @"Product IDs don't match");
  XCTAssertNil(o.sscc, @"Expected sscc to be nil");
  XCTAssertNil(o.lotNumber, @"Expected lot number to be nil");
  XCTAssertNil(o.productionDate, @"Expected production dates to be nil");
  XCTAssertEqualObjects(o.packagingDate, @"001205", @"Packaging dates don't match");
  XCTAssertNil(o.bestBeforeDate, @"Expected best before date to be nil");
  XCTAssertNil(o.expirationDate, @"Expected expiration date to be nil");
  XCTAssertEqualObjects(o.weight, @"6544", @"Weights don't match");
  XCTAssertEqualObjects(o.weightType, @"KG", @"Weight types don't match");
  XCTAssertEqualObjects(o.weightIncrement, @"2", @"Weight increments don't match");
  XCTAssertEqualObjects(o.price, @"5", @"Prices don't match");
  XCTAssertEqualObjects(o.priceIncrement, @"2", @"Price increments don't match");
  XCTAssertEqualObjects(o.priceCurrency, @"445", @"Price currencies don't match");
  XCTAssertEqualObjects(o.uncommonAIs, uncommonAIs, @"Uncommon AIs don't match");
}

@end

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

#import "ZXBarcodeFormat.h"
#import "ZXExpandedProductParsedResult.h"
#import "ZXExpandedProductParsedResultTestCase.h"
#import "ZXExpandedProductResultParser.h"
#import "ZXResult.h"

@implementation ZXExpandedProductParsedResultTestCase

- (void)test_RSSExpanded {
  NSDictionary *uncommonAIs = [NSDictionary dictionaryWithObject:@"544654" forKey:@"123"];
  ZXResult *result = [ZXResult resultWithText:@"(01)66546(13)001205(3932)4455(3102)6544(123)544654"
                                     rawBytes:NULL
                                       length:0
                                 resultPoints:nil
                                       format:kBarcodeFormatRSSExpanded];
  ZXExpandedProductParsedResult *o = (ZXExpandedProductParsedResult *)[[[ZXExpandedProductResultParser alloc] init] parse:result];
  STAssertNotNil(o, @"Expected result to be non-nil");
  STAssertEqualObjects(o.productID, @"66546", @"Product IDs don't match");
  STAssertNil(o.sscc, @"Expected sscc to be nil");
  STAssertNil(o.lotNumber, @"Expected lot number to be nil");
  STAssertNil(o.productionDate, @"Expected production dates to be nil");
  STAssertEqualObjects(o.packagingDate, @"001205", @"Packaging dates don't match");
  STAssertNil(o.bestBeforeDate, @"Expected best before date to be nil");
  STAssertNil(o.expirationDate, @"Expected expiration date to be nil");
  STAssertEqualObjects(o.weight, @"6544", @"Weights don't match");
  STAssertEqualObjects(o.weightType, @"KG", @"Weight types don't match");
  STAssertEqualObjects(o.weightIncrement, @"2", @"Weight increments don't match");
  STAssertEqualObjects(o.price, @"5", @"Prices don't match");
  STAssertEqualObjects(o.priceIncrement, @"2", @"Price increments don't match");
  STAssertEqualObjects(o.priceCurrency, @"445", @"Price currencies don't match");
  STAssertEqualObjects(o.uncommonAIs, uncommonAIs, @"Uncommon AIs don't match");
}

@end

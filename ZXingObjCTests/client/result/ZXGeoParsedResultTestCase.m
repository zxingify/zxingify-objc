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

#import "ZXGeoParsedResultTestCase.h"

@implementation ZXGeoParsedResultTestCase

static double EPSILON = 0.0000000001;

- (void)testGeo {
  [self doTestWithContents:@"geo:1,2" latitude:1.0 longitude:2.0 altitude:0.0 query:nil];
  [self doTestWithContents:@"geo:80.33,-32.3344,3.35" latitude:80.33 longitude:-32.3344 altitude:3.35 query:nil];
  [self doTestWithContents:@"geo:-20.33,132.3344,0.01" latitude:-20.33 longitude:132.3344 altitude:0.01 query:nil];
  [self doTestWithContents:@"geo:-20.33,132.3344,0.01?q=foobar" latitude:-20.33 longitude:132.3344 altitude:0.01 query:@"q=foobar"];
  [self doTestWithContents:@"GEO:-20.33,132.3344,0.01?q=foobar" latitude:-20.33 longitude:132.3344 altitude:0.01 query:@"q=foobar"];
}

- (void)doTestWithContents:(NSString *)contents
                  latitude:(double)latitude
                 longitude:(double)longitude
                  altitude:(double)altitude
                     query:(NSString *)query {
  ZXResult *fakeResult = [ZXResult resultWithText:contents rawBytes:nil resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];
  XCTAssertEqual(result.type, kParsedResultTypeGeo, @"Types don't match");
  ZXGeoParsedResult *geoResult = (ZXGeoParsedResult *)result;
  XCTAssertEqualWithAccuracy(geoResult.latitude, latitude, EPSILON, @"Latitudes don't match");
  XCTAssertEqualWithAccuracy(geoResult.longitude, longitude, EPSILON, @"Longitudes don't match");
  XCTAssertEqualWithAccuracy(geoResult.altitude, altitude, EPSILON, @"Altitudes don't match");
  XCTAssertEqualObjects(geoResult.query, query, @"Queries don't match");
}

@end

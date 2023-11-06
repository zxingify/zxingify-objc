/*
 * Copyright 2013 ZXing authors
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

#import "ZXGenericGFPolyTestCase.h"
#import "ZXGenericGFPoly.h"
#import "ZXGenericGF.h"

@implementation ZXGenericGFPolyTestCase

static ZXGenericGF *FIELD = nil;

+ (void)initialize {
  FIELD = [ZXGenericGF QrCodeField256];
}

- (void)testPolynomialString {
  XCTAssertEqualObjects(@"0", [FIELD.zero description]);
  XCTAssertEqualObjects(@"-1", [[FIELD buildMonomial:0 coefficient:-1] description]);
  ZXGenericGFPoly *p = [[ZXGenericGFPoly alloc] initWithField:FIELD coefficients:[[ZXIntArray alloc] initWithInts:3, 0, -2, 1, 1, -1]];
  XCTAssertEqualObjects(@"a^25x^4 - ax^2 + x + 1", [p description]);
  p = [[ZXGenericGFPoly alloc] initWithField:FIELD coefficients:[[ZXIntArray alloc] initWithInts:3, -1]];
  XCTAssertEqualObjects(@"a^25", [p description]);
}

- (void)testZero {
  XCTAssertEqualObjects(FIELD.zero, [FIELD buildMonomial:1 coefficient:0]);
  XCTAssertEqualObjects(FIELD.zero, [[FIELD buildMonomial:1 coefficient:2] multiplyScalar:0]);
}

- (void)testEvaluate {
  XCTAssertEqual(3, [[FIELD buildMonomial:0 coefficient:3] evaluateAt:0]);
}

@end

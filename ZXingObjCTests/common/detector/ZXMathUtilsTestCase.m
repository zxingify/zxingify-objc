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

#import "ZXMathUtils.h"
#import "ZXMathUtilsTestCase.h"

@implementation ZXMathUtilsTestCase

- (void)testRound {
  XCTAssertEqual(-1, [ZXMathUtils round:-1.0f]);
  XCTAssertEqual(0, [ZXMathUtils round:0.0f]);
  XCTAssertEqual(1, [ZXMathUtils round:1.0f]);

  XCTAssertEqual(2, [ZXMathUtils round:1.9f]);
  XCTAssertEqual(2, [ZXMathUtils round:2.1f]);

  XCTAssertEqual(3, [ZXMathUtils round:2.5f]);

  XCTAssertEqual(-2, [ZXMathUtils round:-1.9f]);
  XCTAssertEqual(-2, [ZXMathUtils round:-2.1f]);

  XCTAssertEqual(-3, [ZXMathUtils round:-2.5f]); // This differs from Math.round()
}

@end

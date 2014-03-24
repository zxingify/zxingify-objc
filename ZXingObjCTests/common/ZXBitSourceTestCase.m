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

#import "ZXBitSourceTestCase.h"

@implementation ZXBitSourceTestCase

- (void)testSource {
  ZXByteArray *bytes = [[ZXByteArray alloc] initWithBytes:1, 2, 3, 4, 5, -1];
  ZXBitSource *source = [[ZXBitSource alloc] initWithBytes:bytes];
  XCTAssertEqual(40, source.available);
  XCTAssertEqual(0, [source readBits:1]);
  XCTAssertEqual(39, source.available);
  XCTAssertEqual(0, [source readBits:6]);
  XCTAssertEqual(33, source.available);
  XCTAssertEqual(1, [source readBits:1]);
  XCTAssertEqual(32, source.available);
  XCTAssertEqual(2, [source readBits:8]);
  XCTAssertEqual(24, source.available);
  XCTAssertEqual(12, [source readBits:10]);
  XCTAssertEqual(14, source.available);
  XCTAssertEqual(16, [source readBits:8]);
  XCTAssertEqual(6, source.available);
  XCTAssertEqual(5, [source readBits:6]);
  XCTAssertEqual(0, source.available);
}

@end

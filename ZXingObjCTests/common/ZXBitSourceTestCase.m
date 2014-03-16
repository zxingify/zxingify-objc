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
  XCTAssertEqual(source.available, 40, @"Expected source.available to 40");
  XCTAssertEqual([source readBits:1], 0, @"Expected [source readBits:1] to 0");
  XCTAssertEqual(source.available, 39, @"Expected source.available to 39");
  XCTAssertEqual([source readBits:6], 0, @"Expected [source readBits:6] to 0");
  XCTAssertEqual(source.available, 33, @"Expected source.available to 33");
  XCTAssertEqual([source readBits:1], 1, @"Expected [source readBits:1] to 1");
  XCTAssertEqual(source.available, 32, @"Expected source.available to 32");
  XCTAssertEqual([source readBits:8], 2, @"Expected [source readBits:1] to 1");
  XCTAssertEqual(source.available, 24, @"Expected source.available to 24");
  XCTAssertEqual([source readBits:10], 12, @"Expected [source readBits:10] to 1");
  XCTAssertEqual(source.available, 14, @"Expected source.available to 14");
  XCTAssertEqual([source readBits:8], 16, @"Expected [source readBits:8] to 16");
  XCTAssertEqual(source.available, 6, @"Expected source.available to 6");
  XCTAssertEqual([source readBits:6], 5, @"Expected [source readBits:6] to 5");
  XCTAssertEqual(source.available, 0, @"Expected source.available to 0");
}

@end

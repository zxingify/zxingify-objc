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

#import "ZXEAN8WriterTestCase.h"

@implementation ZXEAN8WriterTestCase

- (void)testEncode {
  NSString *testStr = @"0001010001011010111101111010110111010101001110111001010001001011100101000";
  ZXBitMatrix *result = [[[ZXEAN8Writer alloc] init] encode:@"96385074"
                                                     format:kBarcodeFormatEan8
                                                      width:(int)testStr.length
                                                     height:0
                                                      error:nil];
  for (int i = 0; i < testStr.length; i++) {
    XCTAssertEqual([testStr characterAtIndex:i] == '1', [result getX:i y:0], @"Element %d", i);
  }
}

@end

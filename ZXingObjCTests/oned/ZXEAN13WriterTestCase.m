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

#import "ZXEAN13WriterTestCase.h"

@implementation ZXEAN13WriterTestCase

- (void)testEncode {
  NSString *testStr = @"00010100010110100111011001100100110111101001110101010110011011011001000010101110010011101000100101000";
  ZXBitMatrix *result = [[[ZXEAN13Writer alloc] init] encode:@"5901234123457"
                                                      format:kBarcodeFormatEan13
                                                       width:(int)testStr.length
                                                      height:0
                                                       error:nil];
  for (int i = 0; i < testStr.length; i++) {
    XCTAssertEqual([result getX:i y:0], [testStr characterAtIndex:i] == '1', @"Element %d", i);
  }
}

- (void)testEncodeWithWrongFormatReturnsError {
    NSError *error;
    ZXBitMatrix *result = [[[ZXEAN13Writer alloc] init] encode:@"5901234123457"
                                                        format:kBarcodeFormatEan8
                                                         width:10
                                                        height:0
                                                         error:&error];
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

- (void)testEncodeWithWrongContentLengthReturnsError {
    NSError *error;
    ZXBoolArray *result = [[[ZXEAN13Writer alloc] init] encode:@"12345" error:&error];
    
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

- (void)testEncodeWithWrongCheksumReturnsError {
    NSError *error;
    ZXBoolArray *result = [[[ZXEAN13Writer alloc] init] encode:@"5901234123458" error:&error];
    
    XCTAssertNil(result);
    
    if (!error || error.code != ZXWriterError) {
        XCTFail(@"ZXWriterError expected");
    }
}

@end

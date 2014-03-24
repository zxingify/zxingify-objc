/*
 * Copyright 2014 ZXing authors
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

#import "ZXCode128WriterTestCase.h"

const NSString *ZX_FNC1 = @"11110101110";
const NSString *ZX_FNC2 = @"11110101000";
const NSString *ZX_FNC3 = @"10111100010";
const NSString *ZX_FNC4 = @"10111101110";
const NSString *ZX_START_CODE_B = @"11010010000";
const NSString *ZX_QUIET_SPACE = @"00000";
const NSString *ZX_STOP = @"1100011101011";

@interface ZXCode128WriterTestCase ()

@property (nonatomic, strong) id<ZXWriter> writer;

@end

@implementation ZXCode128WriterTestCase

- (void)setUp {
  self.writer = [[ZXCode128Writer alloc] init];
}

- (void)testEncodeWithFunc3 {
  NSString *toEncode = [NSString stringWithFormat:@"%C123", (unichar)L'\u00f3'];
  //                                                                                                                   "1"            "2"             "3"          check digit 51
  NSString *expected = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", ZX_QUIET_SPACE, ZX_START_CODE_B, ZX_FNC3, @"10011100110", @"11001110010", @"11001011100", @"11101000110", ZX_STOP, ZX_QUIET_SPACE];

  ZXBitMatrix *result = [self.writer encode:toEncode format:kBarcodeFormatCode128 width:0 height:0 error:nil];

  NSString *actual = [self matrixToString:result];
  XCTAssertEqualObjects(actual, expected);
}

- (void)testEncodeWithFunc2 {
  NSString *toEncode = [NSString stringWithFormat:@"%C123", (unichar)L'\u00f2'];
  //                                                                                                                   "1"            "2"             "3"          check digit 56
  NSString *expected = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", ZX_QUIET_SPACE, ZX_START_CODE_B, ZX_FNC2, @"10011100110", @"11001110010", @"11001011100", @"11100010110", ZX_STOP, ZX_QUIET_SPACE];

  ZXBitMatrix *result = [self.writer encode:toEncode format:kBarcodeFormatCode128 width:0 height:0 error:nil];

  NSString *actual = [self matrixToString:result];
  XCTAssertEqualObjects(actual, expected);
}

- (void)testEncodeWithFunc1 {
  NSString *toEncode = [NSString stringWithFormat:@"%C123", (unichar)L'\u00f1'];
  //                                                                                                                   "1"            "2"             "3"          check digit 61
  NSString *expected = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", ZX_QUIET_SPACE, ZX_START_CODE_B, ZX_FNC1, @"10011100110", @"11001110010", @"11001011100", @"11001000010", ZX_STOP, ZX_QUIET_SPACE];

  ZXBitMatrix *result = [self.writer encode:toEncode format:kBarcodeFormatCode128 width:0 height:0 error:nil];

  NSString *actual = [self matrixToString:result];
  XCTAssertEqualObjects(actual, expected);
}

- (void)testEncodeWithFunc4 {
  NSString *toEncode = [NSString stringWithFormat:@"%C123", (unichar)L'\u00f4'];
  //                                                                                                                   "1"            "2"             "3"          check digit 59
  NSString *expected = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", ZX_QUIET_SPACE, ZX_START_CODE_B, ZX_FNC4, @"10011100110", @"11001110010", @"11001011100", @"11100011010", ZX_STOP, ZX_QUIET_SPACE];

  ZXBitMatrix *result = [self.writer encode:toEncode format:kBarcodeFormatCode128 width:0 height:0 error:nil];

  NSString *actual = [self matrixToString:result];
  XCTAssertEqualObjects(actual, expected);
}

- (NSString *)matrixToString:(ZXBitMatrix *)matrix {
  NSMutableString *builder = [NSMutableString stringWithCapacity:matrix.width];
  for (int i = 0; i < matrix.width; i++) {
    [builder appendString:[matrix getX:i y:0] ? @"1" : @"0"];
  }
  return builder;
}

@end

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
#import "ZXCode128Reader.h"

const NSString *ZX_FNC1 = @"11110101110";
const NSString *ZX_FNC2 = @"11110101000";
const NSString *ZX_FNC3 = @"10111100010";
const NSString *ZX_FNC4A = @"11101011110";
const NSString *ZX_FNC4B = @"10111101110";
const NSString *ZX_START_CODE_A = @"11010000100";
const NSString *ZX_START_CODE_B = @"11010010000";
const NSString *ZX_START_CODE_C = @"11010011100";
const NSString *ZX_SWITCH_CODE_A = @"11101011110";
const NSString *ZX_SWITCH_CODE_B = @"10111101110";
const NSString *ZX_QUIET_SPACE = @"00000";
const NSString *ZX_STOP = @"1100011101011";
const NSString *ZX_LF = @"10000110010";

@interface ZXCode128WriterTestCase ()

@property (nonatomic, strong) id<ZXWriter> writer;
@property (nonatomic, strong) ZXCode128Reader *reader;

@end

@implementation ZXCode128WriterTestCase

- (void)setUp {
  self.writer = [[ZXCode128Writer alloc] init];
  self.reader = [[ZXCode128Reader alloc] init];
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
  //                                                                                                                   "12"                             "3"        check digit 92
  NSString *expected = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", ZX_QUIET_SPACE, ZX_START_CODE_C, ZX_FNC1, @"10110011100", ZX_SWITCH_CODE_B, @"11001011100", @"10101111000", ZX_STOP, ZX_QUIET_SPACE];

  ZXBitMatrix *result = [self.writer encode:toEncode format:kBarcodeFormatCode128 width:0 height:0 error:nil];

  NSString *actual = [self matrixToString:result];
  XCTAssertEqualObjects(actual, expected);
}

- (void)testEncodeWithFunc4 {
  NSString *toEncode = [NSString stringWithFormat:@"%C123", (unichar)L'\u00f4'];
  //                                                                                                                   "1"            "2"             "3"          check digit 59
  NSString *expected = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", ZX_QUIET_SPACE, ZX_START_CODE_B, ZX_FNC4B, @"10011100110", @"11001110010", @"11001011100", @"11100011010", ZX_STOP, ZX_QUIET_SPACE];

  ZXBitMatrix *result = [self.writer encode:toEncode format:kBarcodeFormatCode128 width:0 height:0 error:nil];

  NSString *actual = [self matrixToString:result];
  XCTAssertEqualObjects(actual, expected);
}

- (void)testEncodeWithFncsAndNumberInCodesetA {
  NSString *toEncode = [NSString stringWithFormat:@"\n%C%C1\n", (unichar) 0x00f1, 0x00f4];
  // start with A switch to B and back to A
  //                                                      "\0"            "A"             "B"             Switch to B     "a"             "b"             Switch to A     "\u0010"        check digit
  NSString *expected = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@", ZX_QUIET_SPACE, ZX_START_CODE_A, ZX_LF, ZX_FNC1, ZX_FNC4A, @"10011100110", ZX_LF, @"10101111000", ZX_STOP, ZX_QUIET_SPACE];

  ZXBitMatrix *result = [self.writer encode:toEncode format:kBarcodeFormatCode128 width:0 height:0 error:nil];

  NSString *actual = [self matrixToString:result];
  XCTAssertEqualObjects(actual, expected);
}

- (void)testEncodeSwitchBetweenCodesetsAAndBStartsWithA {
  NSString *toEncode = [NSString stringWithFormat:@"\0ABab%C", (unichar) 0x0010];
  // start with A switch to B and back to A
  //                                                      "\0"            "A"             "B"             Switch to B     "a"             "b"             Switch to A     "\u0010"        check digit
  NSString *expected = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@", ZX_QUIET_SPACE, ZX_START_CODE_A, @"10100001100", @"10100011000", @"10001011000", ZX_SWITCH_CODE_B, @"10010110000", @"10010000110", ZX_SWITCH_CODE_A, @"10100111100", @"11001110100", ZX_STOP, ZX_QUIET_SPACE];

  ZXBitMatrix *result = [self.writer encode:toEncode format:kBarcodeFormatCode128 width:0 height:0 error:nil];

  NSString *actual = [self matrixToString:result];
  XCTAssertEqualObjects(actual, expected);
}

- (void)testEncodeSwitchBetweenCodesetsAAndBStartsWithB {
  NSString *toEncode = [NSString stringWithFormat:@"ab\0ab", (unichar) 0x0010];
  // start with B switch to A and back to B
  //                                                "a"             "b"             Switch to A     "\0             "Switch to B"   "a"             "b"             check digit
  NSString *expected = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@", ZX_QUIET_SPACE, ZX_START_CODE_B, @"10010110000", @"10010000110", ZX_SWITCH_CODE_A, @"10100001100", ZX_SWITCH_CODE_B, @"10010110000", @"10010000110", @"11010001110", ZX_STOP, ZX_QUIET_SPACE];

  ZXBitMatrix *result = [self.writer encode:toEncode format:kBarcodeFormatCode128 width:0 height:0 error:nil];

  NSString *actual = [self matrixToString:result];
  XCTAssertEqualObjects(actual, expected);
}

- (void)testRoundtrip {
  NSString *toEncode = [NSString stringWithFormat:@"%C10958%C17160526", (unichar)L'\u00f1',  (unichar)L'\u00f1'];
  NSString *expected = @"1095817160526";
  ZXBitMatrix *encResult = [self.writer encode:toEncode format:kBarcodeFormatCode128 width:0 height:0 error:nil];
  ZXBitArray *row = [encResult rowAtY:0 row:nil];
  ZXResult *decResult = [self.reader decodeRow:0 row:row hints:nil error:nil];
  NSString *actual = decResult.text;
  XCTAssertEqualObjects(expected, actual);
}

- (NSString *)matrixToString:(ZXBitMatrix *)matrix {
  NSMutableString *builder = [NSMutableString stringWithCapacity:matrix.width];
  for (int i = 0; i < matrix.width; i++) {
    [builder appendString:[matrix getX:i y:0] ? @"1" : @"0"];
  }
  return builder;
}

@end

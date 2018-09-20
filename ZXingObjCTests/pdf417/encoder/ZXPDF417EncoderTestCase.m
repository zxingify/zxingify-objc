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

#import "ZXPDF417HighLevelEncoder.h"
#import "ZXPDF417EncoderTestCase.h"

@implementation ZXPDF417EncoderTestCase

- (void)testEncodeAuto {
  NSString *encoded = [ZXPDF417HighLevelEncoder encodeHighLevel:@"ABCD"
                                                     compaction:ZXPDF417CompactionAuto
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
  NSString *expected = [NSString stringWithFormat:@"%C%C%CABCD", (unichar)0x039f, (unichar)0x001A, (unichar)0x0385];
  XCTAssertEqualObjects(expected, encoded);
}

- (void)testEncodeText {
  NSString *encoded = [ZXPDF417HighLevelEncoder encodeHighLevel:@"ABCD"
                                                     compaction:ZXPDF417CompactionText
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
  NSString *expected = [NSString stringWithFormat:@"Ο%C%C?", (unichar)0x001A, (unichar)0x0001];
  XCTAssertEqualObjects(expected, encoded);
}

- (void)testEncodeNumeric {
  NSString *encoded = [ZXPDF417HighLevelEncoder encodeHighLevel:@"1234"
                                                     compaction:ZXPDF417CompactionNumeric
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
  NSString *expected = [NSString stringWithFormat:@"%C%C%C\f%C", (unichar)0x039f, (unichar)0x001A, (unichar)0x0386, (unichar)0x01b2];
  XCTAssertEqualObjects(expected, encoded);
}

- (void)testEncodeByte {
  NSString *encoded = [ZXPDF417HighLevelEncoder encodeHighLevel:@"abcd"
                                                     compaction:ZXPDF417CompactionByte
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
  NSString *expected = [NSString stringWithFormat:@"%C%C%Cabcd", (unichar)0x039f, (unichar)0x001A, (unichar)0x0385];
  XCTAssertEqualObjects(expected, encoded);
}

- (void)testEncodeAutoWithSpecialChars {
  // just check if this does not throw an error
  NSError *error;
  [ZXPDF417HighLevelEncoder encodeHighLevel:@"1%§s ?aG$" compaction:ZXPDF417CompactionAuto encoding:NSUTF8StringEncoding error:&error];
  XCTAssertNil(error);
}

- (void)testEncodeIso88591WithSpecialChars {
  // just check if this does not throw an error
  NSError *error;
  [ZXPDF417HighLevelEncoder encodeHighLevel:@"asdfg§asd" compaction:ZXPDF417CompactionAuto encoding:NSISOLatin1StringEncoding error:&error];
  XCTAssertNil(error);
}

@end

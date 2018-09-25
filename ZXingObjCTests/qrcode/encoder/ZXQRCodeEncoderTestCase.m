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

#import "ZXQRCodeEncoderTestCase.h"

@interface ZXQRCodeEncoder (PrivateMethods)

+ (ZXQRCodeMode *)chooseMode:(NSString *)content;

@end

@implementation ZXQRCodeEncoderTestCase

- (void)testGetAlphanumericCode {
  // The first ten code points are numbers.
  for (int i = 0; i < 10; ++i) {
    XCTAssertEqual(i, [ZXQRCodeEncoder alphanumericCode:'0' + i]);
  }

  // The next 26 code points are capital alphabet letters.
  for (int i = 10; i < 36; ++i) {
    XCTAssertEqual(i, [ZXQRCodeEncoder alphanumericCode:'A' + i - 10]);
  }

  // Others are symbol letters
  XCTAssertEqual(36, [ZXQRCodeEncoder alphanumericCode:' ']);
  XCTAssertEqual(37, [ZXQRCodeEncoder alphanumericCode:'$']);
  XCTAssertEqual(38, [ZXQRCodeEncoder alphanumericCode:'%']);
  XCTAssertEqual(39, [ZXQRCodeEncoder alphanumericCode:'*']);
  XCTAssertEqual(40, [ZXQRCodeEncoder alphanumericCode:'+']);
  XCTAssertEqual(41, [ZXQRCodeEncoder alphanumericCode:'-']);
  XCTAssertEqual(42, [ZXQRCodeEncoder alphanumericCode:'.']);
  XCTAssertEqual(43, [ZXQRCodeEncoder alphanumericCode:'/']);
  XCTAssertEqual(44, [ZXQRCodeEncoder alphanumericCode:':']);

  // Should return -1 for other letters;
  XCTAssertEqual(-1, [ZXQRCodeEncoder alphanumericCode:'a']);
  XCTAssertEqual(-1, [ZXQRCodeEncoder alphanumericCode:'#']);
  XCTAssertEqual(-1, [ZXQRCodeEncoder alphanumericCode:'\0']);
}

- (void)testChooseMode {
  // Numeric mode.
  XCTAssertEqualObjects([ZXQRCodeMode numericMode], [ZXQRCodeEncoder chooseMode:@"0"]);
  XCTAssertEqualObjects([ZXQRCodeMode numericMode], [ZXQRCodeEncoder chooseMode:@"0123456789"]);
  // Alphanumeric mode.
  XCTAssertEqualObjects([ZXQRCodeMode alphanumericMode], [ZXQRCodeEncoder chooseMode:@"A"]);
  XCTAssertEqualObjects([ZXQRCodeMode alphanumericMode],
                        [ZXQRCodeEncoder chooseMode:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"]);
  // 8-bit byte mode.
  XCTAssertEqualObjects([ZXQRCodeMode byteMode], [ZXQRCodeEncoder chooseMode:@"a"]);
  XCTAssertEqualObjects([ZXQRCodeMode byteMode], [ZXQRCodeEncoder chooseMode:@"#"]);
  XCTAssertEqualObjects([ZXQRCodeMode byteMode], [ZXQRCodeEncoder chooseMode:@""]);
  // Kanji mode.  We used to use MODE_KANJI for these, but we stopped
  // doing that as we cannot distinguish Shift_JIS from other encodings
  // from data bytes alone.  See also comments in qrcode_encoder.h.

  // AIUE in Hiragana in Shift_JIS
  ZXQRCodeMode *mode = [ZXQRCodeEncoder chooseMode:[self shiftJISString:[[ZXByteArray alloc] initWithBytes:0x8, 0xa, 0x8, 0xa, 0x8, 0xa, 0x8, 0xa6, -1]]];
  XCTAssertEqualObjects([ZXQRCodeMode byteMode], mode);

  // Nihon in Kanji in Shift_JIS.
  mode = [ZXQRCodeEncoder chooseMode:[self shiftJISString:[[ZXByteArray alloc] initWithBytes:0x9, 0xf, 0x9, 0x7b, -1]]];
  XCTAssertEqualObjects([ZXQRCodeMode byteMode], mode);

  // Sou-Utsu-Byou in Kanji in Shift_JIS.
  mode = [ZXQRCodeEncoder chooseMode:[self shiftJISString:[[ZXByteArray alloc] initWithBytes:0xe, 0x4, 0x9, 0x5, 0x9, 0x61, -1]]];
  XCTAssertEqualObjects([ZXQRCodeMode byteMode], mode);
}

- (void)testEncode {
  ZXQRCode *qrCode = [ZXQRCodeEncoder encode:@"ABCDEF" ecLevel:[ZXQRCodeErrorCorrectionLevel errorCorrectionLevelH] error:nil];
  // The following is a valid QR Code that can be read by cell phones.
  NSString *expected =
    @"<<\n"
         " mode: ALPHANUMERIC\n"
         " ecLevel: H\n"
         " version: 1\n"
         " maskPattern: 4\n"
         " matrix:\n"
         " 1 1 1 1 1 1 1 0 0 1 0 1 0 0 1 1 1 1 1 1 1\n"
         " 1 0 0 0 0 0 1 0 1 0 1 0 1 0 1 0 0 0 0 0 1\n"
         " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1 0 1\n"
         " 1 0 1 1 1 0 1 0 0 1 0 0 1 0 1 0 1 1 1 0 1\n"
         " 1 0 1 1 1 0 1 0 0 1 0 1 0 0 1 0 1 1 1 0 1\n"
         " 1 0 0 0 0 0 1 0 1 0 0 1 1 0 1 0 0 0 0 0 1\n"
         " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
         " 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0\n"
         " 0 0 0 0 1 1 1 1 0 1 1 0 1 0 1 1 0 0 0 1 0\n"
         " 0 0 0 0 1 1 0 1 1 1 0 0 1 1 1 1 0 1 1 0 1\n"
         " 1 0 0 0 0 1 1 0 0 1 0 1 0 0 0 1 1 1 0 1 1\n"
         " 1 0 0 1 1 1 0 0 1 1 1 1 0 0 0 0 1 0 0 0 0\n"
         " 0 1 1 1 1 1 1 0 1 0 1 0 1 1 1 0 0 1 1 0 0\n"
         " 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1 0 0 0 1 0 1\n"
         " 1 1 1 1 1 1 1 0 1 1 1 1 0 0 0 0 0 1 1 0 0\n"
         " 1 0 0 0 0 0 1 0 1 1 0 1 0 0 0 1 0 1 1 1 1\n"
         " 1 0 1 1 1 0 1 0 1 0 0 1 0 0 0 1 1 0 0 1 1\n"
         " 1 0 1 1 1 0 1 0 0 0 1 1 0 1 0 0 0 0 1 1 1\n"
         " 1 0 1 1 1 0 1 0 0 1 0 1 0 0 0 1 1 0 0 0 0\n"
         " 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 1 0 0 0 1\n"
         " 1 1 1 1 1 1 1 0 0 0 1 0 0 1 0 0 0 0 1 1 1\n"
         ">>\n";
  XCTAssertEqualObjects(expected, [qrCode description]);
}

- (void)testEncodeKanjiMode {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.encoding = NSShiftJISStringEncoding;
  // Nihon in Kanji
  ZXQRCode *qrCode = [ZXQRCodeEncoder encode:@"\u65e5\u672c" ecLevel:[ZXQRCodeErrorCorrectionLevel errorCorrectionLevelM] hints:hints error:nil];
  NSString *expected =
  @"<<\n"
  " mode: KANJI\n"
  " ecLevel: M\n"
  " version: 1\n"
  " maskPattern: 0\n"
  " matrix:\n"
  " 1 1 1 1 1 1 1 0 0 1 0 1 0 0 1 1 1 1 1 1 1\n"
  " 1 0 0 0 0 0 1 0 1 1 0 0 0 0 1 0 0 0 0 0 1\n"
  " 1 0 1 1 1 0 1 0 0 1 1 1 1 0 1 0 1 1 1 0 1\n"
  " 1 0 1 1 1 0 1 0 0 0 0 0 1 0 1 0 1 1 1 0 1\n"
  " 1 0 1 1 1 0 1 0 1 1 1 1 1 0 1 0 1 1 1 0 1\n"
  " 1 0 0 0 0 0 1 0 0 1 1 1 0 0 1 0 0 0 0 0 1\n"
  " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
  " 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0\n"
  " 1 0 1 0 1 0 1 0 0 0 1 0 1 0 0 0 1 0 0 1 0\n"
  " 1 1 0 1 0 0 0 1 0 1 1 1 0 1 0 1 0 1 0 0 0\n"
  " 0 1 0 0 0 0 1 1 1 1 1 1 0 1 1 1 0 1 0 1 0\n"
  " 1 1 1 0 0 1 0 1 0 0 0 1 1 1 0 1 1 0 1 0 0\n"
  " 0 1 1 0 0 1 1 0 1 1 0 1 0 1 1 1 0 1 0 0 1\n"
  " 0 0 0 0 0 0 0 0 1 0 1 0 0 0 1 0 0 0 1 0 1\n"
  " 1 1 1 1 1 1 1 0 0 0 0 0 1 0 0 0 1 0 0 1 1\n"
  " 1 0 0 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 1 1\n"
  " 1 0 1 1 1 0 1 0 1 0 0 0 1 0 1 0 1 0 1 0 1\n"
  " 1 0 1 1 1 0 1 0 0 0 0 1 0 1 0 1 0 1 0 1 0\n"
  " 1 0 1 1 1 0 1 0 1 0 1 1 0 1 1 1 0 0 1 0 1\n"
  " 1 0 0 0 0 0 1 0 0 0 0 1 1 1 0 1 1 1 0 1 0\n" 
  " 1 1 1 1 1 1 1 0 1 1 0 1 0 1 1 1 0 0 1 0 0\n"
  ">>\n";
  XCTAssertEqualObjects(expected, [qrCode description]);
}

- (void)testEncodeShiftjisNumeric {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.encoding = NSShiftJISStringEncoding;
  ZXQRCode *qrCode = [ZXQRCodeEncoder encode:@"0123" ecLevel:[ZXQRCodeErrorCorrectionLevel errorCorrectionLevelM] hints:hints error:nil];
  NSString *expected =
  @"<<\n"
  " mode: NUMERIC\n"
  " ecLevel: M\n"
  " version: 1\n"
  " maskPattern: 2\n"
  " matrix:\n"
  " 1 1 1 1 1 1 1 0 0 1 1 0 1 0 1 1 1 1 1 1 1\n"
  " 1 0 0 0 0 0 1 0 0 1 0 0 1 0 1 0 0 0 0 0 1\n"
  " 1 0 1 1 1 0 1 0 1 0 0 0 0 0 1 0 1 1 1 0 1\n"
  " 1 0 1 1 1 0 1 0 1 0 1 1 1 0 1 0 1 1 1 0 1\n"
  " 1 0 1 1 1 0 1 0 1 1 0 1 1 0 1 0 1 1 1 0 1\n"
  " 1 0 0 0 0 0 1 0 1 1 0 0 1 0 1 0 0 0 0 0 1\n"
  " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
  " 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0\n"
  " 1 0 1 1 1 1 1 0 0 1 1 0 1 0 1 1 1 1 1 0 0\n"
  " 1 1 0 0 0 1 0 0 1 0 1 0 1 0 0 1 0 0 1 0 0\n"
  " 0 1 1 0 1 1 1 1 0 1 1 1 0 1 0 0 1 1 0 1 1\n"
  " 1 0 1 1 0 1 0 1 0 0 1 0 0 0 0 1 1 0 1 0 0\n"
  " 0 0 1 0 0 1 1 1 0 0 0 1 0 1 0 0 1 0 1 0 0\n"
  " 0 0 0 0 0 0 0 0 1 1 0 1 1 1 1 0 0 1 0 0 0\n"
  " 1 1 1 1 1 1 1 0 0 0 1 0 1 0 1 1 0 0 0 0 0\n"
  " 1 0 0 0 0 0 1 0 1 1 0 1 1 1 1 0 0 1 0 1 0\n"
  " 1 0 1 1 1 0 1 0 1 0 1 0 1 0 0 1 0 0 1 0 0\n"
  " 1 0 1 1 1 0 1 0 1 1 1 0 1 0 0 1 0 0 1 0 0\n"
  " 1 0 1 1 1 0 1 0 1 1 0 1 0 1 0 0 1 1 1 0 0\n"
  " 1 0 0 0 0 0 1 0 0 0 1 0 0 0 0 1 1 0 1 1 0\n"
  " 1 1 1 1 1 1 1 0 1 1 0 1 0 1 0 0 1 1 1 0 0\n"
  ">>\n";
  XCTAssertEqualObjects(expected, [qrCode description]);
}

- (void)testEncodeWithVersion {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.qrVersion = @7;
  ZXQRCode *qrCode = [ZXQRCodeEncoder encode:@"ABCDEF" ecLevel:[ZXQRCodeErrorCorrectionLevel errorCorrectionLevelH] hints:hints error:nil];
  XCTAssertTrue([qrCode.description containsString:@" version: 7\n"]);
}

- (void)testEncodeWithVersionTooSmall {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.qrVersion = @3;
  ZXQRCode *qrCode = [ZXQRCodeEncoder encode:@"THISMESSAGEISTOOLONGFORAQRCODEVERSION3" ecLevel:[ZXQRCodeErrorCorrectionLevel errorCorrectionLevelH] hints:hints error:nil];
  XCTAssertNil(qrCode);
}

- (void)testSimpleUTF8ECI {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.encoding = NSUTF8StringEncoding;
  ZXQRCode *qrCode = [ZXQRCodeEncoder encode:@"hello" ecLevel:[ZXQRCodeErrorCorrectionLevel errorCorrectionLevelH] hints:hints error:nil];
  NSString *expected =
    @"<<\n"
         " mode: BYTE\n"
         " ecLevel: H\n"
         " version: 1\n"
         " maskPattern: 6\n"
         " matrix:\n"
         " 1 1 1 1 1 1 1 0 0 0 1 1 0 0 1 1 1 1 1 1 1\n"
         " 1 0 0 0 0 0 1 0 0 0 1 1 0 0 1 0 0 0 0 0 1\n"
         " 1 0 1 1 1 0 1 0 1 0 0 1 1 0 1 0 1 1 1 0 1\n"
         " 1 0 1 1 1 0 1 0 1 0 0 0 1 0 1 0 1 1 1 0 1\n"
         " 1 0 1 1 1 0 1 0 0 1 1 0 0 0 1 0 1 1 1 0 1\n"
         " 1 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0 0 0 1\n"
         " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
         " 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0\n"
         " 0 0 0 1 1 0 1 1 0 0 0 0 1 0 0 0 0 1 1 0 0\n"
         " 0 0 0 0 0 0 0 0 1 1 0 1 0 0 1 0 1 1 1 1 1\n"
         " 1 1 0 0 0 1 1 1 0 0 0 1 1 0 0 1 0 1 0 1 1\n"
         " 0 0 0 0 1 1 0 0 1 0 0 0 0 0 1 0 1 1 0 0 0\n"
         " 0 1 1 0 0 1 1 0 0 1 1 1 0 1 1 1 1 1 1 1 1\n"
         " 0 0 0 0 0 0 0 0 1 1 1 0 1 1 1 1 1 1 1 1 1\n"
         " 1 1 1 1 1 1 1 0 1 0 1 0 0 0 1 0 0 0 0 0 0\n"
         " 1 0 0 0 0 0 1 0 0 1 0 0 0 1 0 0 0 1 1 0 0\n"
         " 1 0 1 1 1 0 1 0 1 0 0 0 1 0 1 0 0 0 1 0 0\n"
         " 1 0 1 1 1 0 1 0 1 1 1 1 0 1 0 0 1 0 1 1 0\n"
         " 1 0 1 1 1 0 1 0 0 1 1 1 0 0 1 0 0 1 0 1 1\n"
         " 1 0 0 0 0 0 1 0 0 0 0 0 0 1 1 0 1 1 0 0 0\n"
         " 1 1 1 1 1 1 1 0 0 0 0 1 0 1 0 0 1 0 1 0 0\n"
         ">>\n";
  XCTAssertEqualObjects(expected, [qrCode description]);
}

- (void)testGS1ModeHeaderWithECI {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.encoding = NSUTF8StringEncoding;
  hints.gs1Format = YES;
  ZXQRCode *qrCode = [ZXQRCodeEncoder encode:@"hello" ecLevel:[ZXQRCodeErrorCorrectionLevel errorCorrectionLevelH] hints:hints error:nil];
  NSString *expected =
  @"<<\n"
  " mode: BYTE\n"
  " ecLevel: H\n"
  " version: 1\n"
  " maskPattern: 5\n"
  " matrix:\n"
  " 1 1 1 1 1 1 1 0 1 0 1 1 0 0 1 1 1 1 1 1 1\n"
  " 1 0 0 0 0 0 1 0 0 1 1 0 0 0 1 0 0 0 0 0 1\n"
  " 1 0 1 1 1 0 1 0 1 1 1 0 0 0 1 0 1 1 1 0 1\n"
  " 1 0 1 1 1 0 1 0 0 1 0 1 0 0 1 0 1 1 1 0 1\n"
  " 1 0 1 1 1 0 1 0 1 0 1 0 0 0 1 0 1 1 1 0 1\n"
  " 1 0 0 0 0 0 1 0 0 1 1 1 1 0 1 0 0 0 0 0 1\n"
  " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
  " 0 0 0 0 0 0 0 0 1 0 1 1 1 0 0 0 0 0 0 0 0\n"
  " 0 0 0 0 0 1 1 0 0 1 1 0 0 0 1 0 1 0 1 0 1\n"
  " 0 1 0 1 1 0 0 1 0 1 1 1 1 1 1 0 1 1 1 0 1\n"
  " 0 1 0 1 1 1 1 0 1 1 0 0 0 1 0 1 0 1 1 0 0\n"
  " 1 1 1 1 0 1 0 1 0 0 1 0 1 0 0 1 1 1 1 0 0\n"
  " 1 0 0 1 0 0 1 1 0 1 1 0 1 0 1 0 0 1 0 0 1\n"
  " 0 0 0 0 0 0 0 0 1 1 1 1 1 0 1 0 1 0 0 1 0\n"
  " 1 1 1 1 1 1 1 0 0 0 1 1 0 0 1 0 0 0 1 1 0\n"
  " 1 0 0 0 0 0 1 0 1 1 0 0 0 0 1 0 1 1 1 0 0\n"
  " 1 0 1 1 1 0 1 0 0 1 0 0 1 0 1 0 1 0 0 0 1\n"
  " 1 0 1 1 1 0 1 0 0 0 0 0 1 1 1 0 1 1 1 1 0\n"
  " 1 0 1 1 1 0 1 0 0 0 1 0 0 1 0 0 1 0 1 1 1\n"
  " 1 0 0 0 0 0 1 0 0 1 0 0 0 1 1 0 0 1 1 1 1\n"
  " 1 1 1 1 1 1 1 0 0 1 1 1 0 1 1 0 1 0 0 1 0\n"
  ">>\n";
  XCTAssertEqualObjects(expected, [qrCode description]);
}

- (void)testEncodeGS1 {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.encoding = NSUTF8StringEncoding;
  hints.gs1Format = YES;
  ZXQRCode *qrCode = [ZXQRCodeEncoder encode:@"100001%11171218" ecLevel:[ZXQRCodeErrorCorrectionLevel errorCorrectionLevelH] hints:hints error:nil];
  NSString *expected =
  @"<<\n"
  " mode: ALPHANUMERIC\n"
  " ecLevel: H\n"
  " version: 2\n"
  " maskPattern: 4\n"
  " matrix:\n"
  " 1 1 1 1 1 1 1 0 0 1 1 1 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
  " 1 0 0 0 0 0 1 0 1 1 0 0 0 0 0 1 1 0 1 0 0 0 0 0 1\n"
  " 1 0 1 1 1 0 1 0 0 0 0 0 1 1 1 0 1 0 1 0 1 1 1 0 1\n"
  " 1 0 1 1 1 0 1 0 0 1 0 1 0 0 1 1 0 0 1 0 1 1 1 0 1\n"
  " 1 0 1 1 1 0 1 0 0 0 1 1 1 0 0 0 1 0 1 0 1 1 1 0 1\n"
  " 1 0 0 0 0 0 1 0 1 1 0 1 1 0 1 1 0 0 1 0 0 0 0 0 1\n"
  " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
  " 0 0 0 0 0 0 0 0 1 1 0 1 1 0 1 1 0 0 0 0 0 0 0 0 0\n"
  " 0 0 0 0 1 1 1 1 0 0 1 1 0 0 0 1 1 0 1 1 0 0 0 1 0\n"
  " 0 1 1 0 1 1 0 0 1 1 1 0 0 0 1 1 1 1 1 1 1 0 0 0 1\n"
  " 0 0 1 1 1 1 1 0 1 1 1 1 1 0 1 0 0 0 0 0 0 1 1 1 0\n"
  " 1 0 1 1 1 0 0 1 1 1 0 1 1 1 1 1 0 1 1 0 1 1 1 0 0\n"
  " 0 1 0 1 0 0 1 1 1 1 1 1 0 0 1 1 0 1 0 0 0 0 0 1 0\n"
  " 1 0 0 1 1 1 0 0 1 1 0 0 0 1 1 0 1 0 1 0 1 0 0 0 0\n"
  " 0 0 1 0 0 1 1 1 0 1 1 0 1 1 1 0 1 1 1 0 1 1 1 1 0\n"
  " 0 0 0 1 1 0 0 1 0 0 1 0 0 1 1 0 0 1 0 0 0 1 1 1 0\n"
  " 1 1 0 1 0 1 1 0 1 0 1 0 0 0 1 1 1 1 1 1 1 0 0 0 0\n"
  " 0 0 0 0 0 0 0 0 1 1 0 1 0 0 0 1 1 0 0 0 1 1 0 1 0\n"
  " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 0 1 0 1 0 0 0 0\n"
  " 1 0 0 0 0 0 1 0 1 1 0 0 0 1 0 1 1 0 0 0 1 0 1 1 0\n"
  " 1 0 1 1 1 0 1 0 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 1\n"
  " 1 0 1 1 1 0 1 0 0 0 0 0 0 1 1 1 0 0 1 1 0 1 0 0 0\n"
  " 1 0 1 1 1 0 1 0 0 0 1 1 0 1 0 1 1 1 0 1 1 0 0 1 0\n"
  " 1 0 0 0 0 0 1 0 0 1 1 0 1 1 1 1 1 0 1 0 1 1 0 0 0\n"
  " 1 1 1 1 1 1 1 0 0 0 1 0 0 0 0 1 1 0 0 1 1 0 0 1 1\n"
  ">>\n";
  XCTAssertEqualObjects(expected, [qrCode description]);
}

- (void)testEncodeGS1WhenHintIsFalse {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.encoding = NSUTF8StringEncoding;
  ZXQRCode *qrCode = [ZXQRCodeEncoder encode:@"ABCDEF" ecLevel:[ZXQRCodeErrorCorrectionLevel errorCorrectionLevelH] hints:hints error:nil];
  NSString *expected =
  @"<<\n"
  " mode: ALPHANUMERIC\n"
  " ecLevel: H\n"
  " version: 1\n"
  " maskPattern: 4\n"
  " matrix:\n"
  " 1 1 1 1 1 1 1 0 0 1 0 1 0 0 1 1 1 1 1 1 1\n"
  " 1 0 0 0 0 0 1 0 1 0 1 0 1 0 1 0 0 0 0 0 1\n"
  " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1 0 1\n"
  " 1 0 1 1 1 0 1 0 0 1 0 0 1 0 1 0 1 1 1 0 1\n"
  " 1 0 1 1 1 0 1 0 0 1 0 1 0 0 1 0 1 1 1 0 1\n"
  " 1 0 0 0 0 0 1 0 1 0 0 1 1 0 1 0 0 0 0 0 1\n"
  " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
  " 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0\n"
  " 0 0 0 0 1 1 1 1 0 1 1 0 1 0 1 1 0 0 0 1 0\n"
  " 0 0 0 0 1 1 0 1 1 1 0 0 1 1 1 1 0 1 1 0 1\n"
  " 1 0 0 0 0 1 1 0 0 1 0 1 0 0 0 1 1 1 0 1 1\n"
  " 1 0 0 1 1 1 0 0 1 1 1 1 0 0 0 0 1 0 0 0 0\n"
  " 0 1 1 1 1 1 1 0 1 0 1 0 1 1 1 0 0 1 1 0 0\n"
  " 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1 0 0 0 1 0 1\n"
  " 1 1 1 1 1 1 1 0 1 1 1 1 0 0 0 0 0 1 1 0 0\n"
  " 1 0 0 0 0 0 1 0 1 1 0 1 0 0 0 1 0 1 1 1 1\n"
  " 1 0 1 1 1 0 1 0 1 0 0 1 0 0 0 1 1 0 0 1 1\n"
  " 1 0 1 1 1 0 1 0 0 0 1 1 0 1 0 0 0 0 1 1 1\n"
  " 1 0 1 1 1 0 1 0 0 1 0 1 0 0 0 1 1 0 0 0 0\n"
  " 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 1 1 0 0 0 1\n"
  " 1 1 1 1 1 1 1 0 0 0 1 0 0 1 0 0 0 0 1 1 1\n"
  ">>\n";
  XCTAssertEqualObjects(expected, [qrCode description]);
}

- (void)testAppendModeInfo {
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendModeInfo:[ZXQRCodeMode numericMode] bits:bits];
  XCTAssertEqualObjects(@" ...X", [bits description]);
}

- (void)testAppendLengthInfo {
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendLengthInfo:1  // 1 letter (1/1).
                      version:[ZXQRCodeVersion versionForNumber:1]
                         mode:[ZXQRCodeMode numericMode]
                         bits:bits
                        error:nil];
  XCTAssertEqualObjects(@" ........ .X", [bits description]);  // 10 bits.
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendLengthInfo:2  // 2 letter (2/1).
                      version:[ZXQRCodeVersion versionForNumber:10]
                         mode:[ZXQRCodeMode alphanumericMode]
                         bits:bits
                        error:nil];
  XCTAssertEqualObjects(@" ........ .X.", [bits description]);  // 11 bits.
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendLengthInfo:255  // 255 letter (255/1).
                      version:[ZXQRCodeVersion versionForNumber:27]
                         mode:[ZXQRCodeMode byteMode]
                         bits:bits
                        error:nil];
  XCTAssertEqualObjects(@" ........ XXXXXXXX", [bits description]);  // 16 bits.
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendLengthInfo:512  // 512 letter (1024/2).
                      version:[ZXQRCodeVersion versionForNumber:40]
                         mode:[ZXQRCodeMode kanjiMode]
                         bits:bits
                        error:nil];
  XCTAssertEqualObjects(@" ..X..... ....", [bits description]);  // 12 bits.
}

- (void)testAppendBytes {
  // Should use appendNumericBytes.
  // 1 = 01 = 0001 in 4 bits.
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendBytes:@"1" mode:[ZXQRCodeMode numericMode] bits:bits encoding:ZX_DEFAULT_BYTE_MODE_ENCODING error:nil];
  XCTAssertEqualObjects(@" ...X", [bits description]);
  // Should use appendAlphanumericBytes.
  // A = 10 = 0xa = 001010 in 6 bits
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendBytes:@"A" mode:[ZXQRCodeMode alphanumericMode] bits:bits encoding:ZX_DEFAULT_BYTE_MODE_ENCODING error:nil];
  XCTAssertEqualObjects(@" ..X.X.", [bits description]);
  // Lower letters such as 'a' cannot be encoded in MODE_ALPHANUMERIC.
  NSError *error;
  if ([ZXQRCodeEncoder appendBytes:@"a" mode:[ZXQRCodeMode alphanumericMode] bits:bits encoding:ZX_DEFAULT_BYTE_MODE_ENCODING error:&error] ||
      error.code != ZXWriterError) {
    XCTFail(@"Expected ZXWriterError");
  }
  // Should use append8BitBytes.
  // 0x61, 0x62, 0x63
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendBytes:@"abc" mode:[ZXQRCodeMode byteMode] bits:bits encoding:ZX_DEFAULT_BYTE_MODE_ENCODING error:nil];
  XCTAssertEqualObjects(@" .XX....X .XX...X. .XX...XX", [bits description]);
  // Anything can be encoded in QRCode.MODE_8BIT_BYTE.
  [ZXQRCodeEncoder appendBytes:@"\0" mode:[ZXQRCodeMode byteMode] bits:bits encoding:ZX_DEFAULT_BYTE_MODE_ENCODING error:nil];
  // Should use appendKanjiBytes.
  // 0x93, 0x5f
  bits = [[ZXBitArray alloc] init];
  ZXByteArray *bytes = [[ZXByteArray alloc] initWithBytes:0x93, 0x5f, -1];
  [ZXQRCodeEncoder appendBytes:[self shiftJISString:bytes] mode:[ZXQRCodeMode kanjiMode] bits:bits encoding:ZX_DEFAULT_BYTE_MODE_ENCODING error:nil];
  XCTAssertEqualObjects(@" .XX.XX.. XXXXX", [bits description]);
}

- (void)testTerminateBits {
  ZXBitArray *v = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder terminateBits:0 bits:v error:nil];
  XCTAssertEqualObjects(@"", [v description]);
  v = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder terminateBits:1 bits:v error:nil];
  XCTAssertEqualObjects(@" ........", [v description]);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0 numBits:3];  // Append 000
  [ZXQRCodeEncoder terminateBits:1 bits:v error:nil];
  XCTAssertEqualObjects(@" ........", [v description]);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0 numBits:5];  // Append 00000
  [ZXQRCodeEncoder terminateBits:1 bits:v error:nil];
  XCTAssertEqualObjects(@" ........", [v description]);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0 numBits:8];  // Append 00000000
  [ZXQRCodeEncoder terminateBits:1 bits:v error:nil];
  XCTAssertEqualObjects(@" ........", [v description]);
  v = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder terminateBits:2 bits:v error:nil];
  XCTAssertEqualObjects(@" ........ XXX.XX..", [v description]);
  v = [[ZXBitArray alloc] init];
  [v appendBits:0 numBits:1];  // Append 0
  [ZXQRCodeEncoder terminateBits:3 bits:v error:nil];
  XCTAssertEqualObjects(@" ........ XXX.XX.. ...X...X", [v description]);
}

- (void)testGetNumDataBytesAndNumECBytesForBlockID {
  int numDataBytes[1] = {0};
  int numEcBytes[1] = {0};
  // Version 1-H.
  [ZXQRCodeEncoder numDataBytesAndNumECBytesForBlockID:26 numDataBytes:9 numRSBlocks:1 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(9, numDataBytes[0]);
  XCTAssertEqual(17, numEcBytes[0]);

  // Version 3-H.  2 blocks.
  [ZXQRCodeEncoder numDataBytesAndNumECBytesForBlockID:70 numDataBytes:26 numRSBlocks:2 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(13, numDataBytes[0]);
  XCTAssertEqual(22, numEcBytes[0]);
  [ZXQRCodeEncoder numDataBytesAndNumECBytesForBlockID:70 numDataBytes:26 numRSBlocks:2 blockID:1
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(13, numDataBytes[0]);
  XCTAssertEqual(22, numEcBytes[0]);

  // Version 7-H. (4 + 1) blocks.
  [ZXQRCodeEncoder numDataBytesAndNumECBytesForBlockID:196 numDataBytes:66 numRSBlocks:5 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(13, numDataBytes[0]);
  XCTAssertEqual(26, numEcBytes[0]);
  [ZXQRCodeEncoder numDataBytesAndNumECBytesForBlockID:196 numDataBytes:66 numRSBlocks:5 blockID:4
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(14, numDataBytes[0]);
  XCTAssertEqual(26, numEcBytes[0]);

  // Version 40-H. (20 + 61) blocks.
  [ZXQRCodeEncoder numDataBytesAndNumECBytesForBlockID:3706 numDataBytes:1276 numRSBlocks:81 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(15, numDataBytes[0]);
  XCTAssertEqual(30, numEcBytes[0]);
  [ZXQRCodeEncoder numDataBytesAndNumECBytesForBlockID:3706 numDataBytes:1276 numRSBlocks:81 blockID:20
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(16, numDataBytes[0]);
  XCTAssertEqual(30, numEcBytes[0]);
  [ZXQRCodeEncoder numDataBytesAndNumECBytesForBlockID:3706 numDataBytes:1276 numRSBlocks:81 blockID:80
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  XCTAssertEqual(16, numDataBytes[0]);
  XCTAssertEqual(30, numEcBytes[0]);
}

- (void)testInterleaveWithECBytes {
  ZXByteArray *dataBytes = [[ZXByteArray alloc] initWithBytes:32, 65, 205, 69, 41, 220, 46, 128, 236, -1];
  ZXBitArray *in = [[ZXBitArray alloc] init];
  for (int i = 0; i < dataBytes.length; i++) {
    [in appendBits:dataBytes.array[i] numBits:8];
  }
  ZXBitArray *out = [ZXQRCodeEncoder interleaveWithECBytes:in numTotalBytes:26 numDataBytes:9 numRSBlocks:1 error:nil];
  ZXByteArray *expected = [[ZXByteArray alloc] initWithBytes:
    // Data bytes.
    32, 65, 205, 69, 41, 220, 46, 128, 236,
    // Error correction bytes.
    42, 159, 74, 221, 244, 169, 239, 150, 138, 70,
    237, 85, 224, 96, 74, 219, 61,
    -1
  ];
  XCTAssertEqual((int)expected.length, out.sizeInBytes);
  ZXByteArray *outArray = [[ZXByteArray alloc] initWithLength:expected.length];
  [out toBytes:0 array:outArray offset:0 numBytes:expected.length];
  for (int x = 0; x < expected.length; x++) {
    XCTAssertEqual(expected.array[x], outArray.array[x]);
  }
  dataBytes = [[ZXByteArray alloc] initWithBytes:
    67, 70, 22, 38, 54, 70, 86, 102, 118, 134, 150, 166, 182,
    198, 214, 230, 247, 7, 23, 39, 55, 71, 87, 103, 119, 135,
    151, 166, 22, 38, 54, 70, 86, 102, 118, 134, 150, 166,
    182, 198, 214, 230, 247, 7, 23, 39, 55, 71, 87, 103, 119,
    135, 151, 160, 236, 17, 236, 17, 236, 17, 236,
    17, -1
  ];
  in = [[ZXBitArray alloc] init];
  for (int i = 0; i < dataBytes.length; i++) {
    [in appendBits:dataBytes.array[i] numBits:8];
  }

  out = [ZXQRCodeEncoder interleaveWithECBytes:in numTotalBytes:134 numDataBytes:62 numRSBlocks:4 error:nil];
  expected = [[ZXByteArray alloc] initWithBytes:
    // Data bytes.
    67, 230, 54, 55, 70, 247, 70, 71, 22, 7, 86, 87, 38, 23, 102, 103, 54, 39,
    118, 119, 70, 55, 134, 135, 86, 71, 150, 151, 102, 87, 166,
    160, 118, 103, 182, 236, 134, 119, 198, 17, 150,
    135, 214, 236, 166, 151, 230, 17, 182,
    166, 247, 236, 198, 22, 7, 17, 214, 38, 23, 236, 39,
    17,
    // Error correction bytes.
    175, 155, 245, 236, 80, 146, 56, 74, 155, 165,
    133, 142, 64, 183, 132, 13, 178, 54, 132, 108, 45,
    113, 53, 50, 214, 98, 193, 152, 233, 147, 50, 71, 65,
    190, 82, 51, 209, 199, 171, 54, 12, 112, 57, 113, 155, 117,
    211, 164, 117, 30, 158, 225, 31, 190, 242, 38,
    140, 61, 179, 154, 214, 138, 147, 87, 27, 96, 77, 47,
    187, 49, 156, 214, -1
  ];
  XCTAssertEqual((int)expected.length, out.sizeInBytes);
  outArray = [[ZXByteArray alloc] initWithLength:expected.length];
  [out toBytes:0 array:outArray offset:0 numBytes:expected.length];
  for (int x = 0; x < expected.length; x++) {
    XCTAssertEqual(expected.array[x], outArray.array[x]);
  }
}

- (void)testAppendNumericBytes {
  // 1 = 01 = 0001 in 4 bits.
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendNumericBytes:@"1" bits:bits];
  XCTAssertEqualObjects(@" ...X", [bits description]);
  // 12 = 0xc = 0001100 in 7 bits.
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendNumericBytes:@"12" bits:bits];
  XCTAssertEqualObjects(@" ...XX..", [bits description]);
  // 123 = 0x7b = 0001111011 in 10 bits.
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendNumericBytes:@"123" bits:bits];
  XCTAssertEqualObjects(@" ...XXXX. XX", [bits description]);
  // 1234 = "123" + "4" = 0001111011 + 0100
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendNumericBytes:@"1234" bits:bits];
  XCTAssertEqualObjects(@" ...XXXX. XX.X..", [bits description]);
  // Empty.
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendNumericBytes:@"" bits:bits];
  XCTAssertEqualObjects(@"", [bits description]);
}

- (void)testAppendAlphanumericBytes {
  // A = 10 = 0xa = 001010 in 6 bits
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendAlphanumericBytes:@"A" bits:bits error:nil];
  XCTAssertEqualObjects(@" ..X.X.", [bits description]);
  // AB = 10 * 45 + 11 = 461 = 0x1cd = 00111001101 in 11 bits
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendAlphanumericBytes:@"AB" bits:bits error:nil];
  XCTAssertEqualObjects(@" ..XXX..X X.X", [bits description]);
  // ABC = "AB" + "C" = 00111001101 + 001100
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendAlphanumericBytes:@"ABC" bits:bits error:nil];
  XCTAssertEqualObjects(@" ..XXX..X X.X..XX. .", [bits description]);
  // Empty.
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendAlphanumericBytes:@"" bits:bits error:nil];
  XCTAssertEqualObjects(@"", [bits description]);
  // Invalid data.
  NSError *error;
  if ([ZXQRCodeEncoder appendAlphanumericBytes:@"abc" bits:[[ZXBitArray alloc] init] error:&error] || error.code != ZXWriterError) {
    XCTFail(@"Expected ZXWriterError");
  }
}

- (void)testAppend8BitBytes {
  // 0x61, 0x62, 0x63
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder append8BitBytes:@"abc" bits:bits encoding:ZX_DEFAULT_BYTE_MODE_ENCODING];
  XCTAssertEqualObjects(@" .XX....X .XX...X. .XX...XX", [bits description]);
  // Empty.
  bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder append8BitBytes:@"" bits:bits encoding:ZX_DEFAULT_BYTE_MODE_ENCODING];
  XCTAssertEqualObjects(@"", [bits description]);
}

// Numbers are from page 21 of JISX0510:2004
- (void)testAppendKanjiBytes {
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXQRCodeEncoder appendKanjiBytes:[self shiftJISString:[[ZXByteArray alloc] initWithBytes:0x93, 0x5f, -1]] bits:bits error:nil];
  XCTAssertEqualObjects(@" .XX.XX.. XXXXX", [bits description]);
  [ZXQRCodeEncoder appendKanjiBytes:[self shiftJISString:[[ZXByteArray alloc] initWithBytes:0xe4, 0xaa, -1]] bits:bits error:nil];
  XCTAssertEqualObjects(@" .XX.XX.. XXXXXXX. X.X.X.X. X.", [bits description]);
}

// Numbers are from http://www.swetake.com/qr/qr3.html and
// http://www.swetake.com/qr/qr9.html
- (void)testGenerateECBytes {
  ZXByteArray *dataBytes = [[ZXByteArray alloc] initWithBytes:32, 65, 205, 69, 41, 220, 46, 128, 236, -1];
  ZXByteArray *ecBytes = [ZXQRCodeEncoder generateECBytes:dataBytes numEcBytesInBlock:17];
  ZXIntArray *expected = [[ZXIntArray alloc] initWithInts:
    42, 159, 74, 221, 244, 169, 239, 150, 138, 70, 237, 85, 224, 96, 74, 219, 61, -1
  ];
  XCTAssertEqual(expected.length, ecBytes.length);
  for (int x = 0; x < expected.length; x++) {
    XCTAssertEqual(expected.array[x], ecBytes.array[x] & 0xFF);
  }
  dataBytes = [[ZXByteArray alloc] initWithBytes:67, 70, 22, 38, 54, 70, 86, 102, 118,
    134, 150, 166, 182, 198, 214, -1];
  ecBytes = [ZXQRCodeEncoder generateECBytes:dataBytes numEcBytesInBlock:18];
  expected = [[ZXIntArray alloc] initWithInts:
    175, 80, 155, 64, 178, 45, 214, 233, 65, 209, 12, 155, 117, 31, 140, 214, 27, 187, -1
  ];
  XCTAssertEqual(expected.length, ecBytes.length);
  for (int x = 0; x < expected.length; x++) {
    XCTAssertEqual(expected.array[x], ecBytes.array[x] & 0xFF);
  }
  // High-order zero coefficient case.
  dataBytes = [[ZXByteArray alloc] initWithBytes:32, 49, 205, 69, 42, 20, 0, 236, 17, -1];
  ecBytes = [ZXQRCodeEncoder generateECBytes:dataBytes numEcBytesInBlock:17];
  expected = [[ZXIntArray alloc] initWithInts:
    0, 3, 130, 179, 194, 0, 55, 211, 110, 79, 98, 72, 170, 96, 211, 137, 213, -1
  ];
  XCTAssertEqual(expected.length, ecBytes.length);
  for (int x = 0; x < expected.length; x++) {
    XCTAssertEqual(expected.array[x], ecBytes.array[x] & 0xFF);
  }
}

- (void)testBugInBitVectorNumBytes {
  // There was a bug in BitVector.sizeInBytes() that caused it to return a
  // smaller-by-one value (ex. 1465 instead of 1466) if the number of bits
  // in the vector is not 8-bit aligned.  In QRCodeEncoder::InitQRCode(),
  // BitVector::sizeInBytes() is used for finding the smallest QR Code
  // version that can fit the given data.  Hence there were corner cases
  // where we chose a wrong QR Code version that cannot fit the given
  // data.  Note that the issue did not occur with MODE_8BIT_BYTE, as the
  // bits in the bit vector are always 8-bit aligned.
  //
  // Before the bug was fixed, the following test didn't pass, because:
  //
  // - MODE_NUMERIC is chosen as all bytes in the data are '0'
  // - The 3518-byte numeric data needs 1466 bytes
  //   - 3518 / 3 * 10 + 7 = 11727 bits = 1465.875 bytes
  //   - 3 numeric bytes are encoded in 10 bits, hence the first
  //     3516 bytes are encoded in 3516 / 3 * 10 = 11720 bits.
  //   - 2 numeric bytes can be encoded in 7 bits, hence the last
  //     2 bytes are encoded in 7 bits.
  // - The version 27 QR Code with the EC level L has 1468 bytes for data.
  //   - 1828 - 360 = 1468
  // - In InitQRCode(), 3 bytes are reserved for a header.  Hence 1465 bytes
  //   (1468 -3) are left for data.
  // - Because of the bug in BitVector::sizeInBytes(), InitQRCode() determines
  //   the given data can fit in 1465 bytes, despite it needs 1466 bytes.
  // - Hence QRCodeEncoder.encode() failed and returned false.
  //   - To be precise, it needs 11727 + 4 (getMode info) + 14 (length info) =
  //     11745 bits = 1468.125 bytes are needed (i.e. cannot fit in 1468
  //     bytes).
  NSMutableString *builder = [NSMutableString stringWithCapacity:3518];
  for (int x = 0; x < 3518; x++) {
    [builder appendString:@"0"];
  }
  ZXQRCode *qrCode = [ZXQRCodeEncoder encode:builder ecLevel:[ZXQRCodeErrorCorrectionLevel errorCorrectionLevelL] error:nil];
  XCTAssertNotNil(qrCode);
}

- (NSString *)shiftJISString:(ZXByteArray *)bytes {
  return [[NSString alloc] initWithBytes:bytes.array length:bytes.length encoding:NSShiftJISStringEncoding];
}

@end

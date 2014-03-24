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

#import "ZXQRCodeTestCase.h"

@implementation ZXQRCodeTestCase

- (void)test {
  ZXQRCode *qrCode = [[ZXQRCode alloc] init];

  // First, test simple setters and getters.
  // We use numbers of version 7-H.
  qrCode.mode = [ZXQRCodeMode byteMode];
  qrCode.ecLevel = [ZXQRCodeErrorCorrectionLevel errorCorrectionLevelH];
  qrCode.version = [ZXQRCodeVersion versionForNumber:7];
  qrCode.maskPattern = 3;

  XCTAssertEqualObjects([ZXQRCodeMode byteMode], qrCode.mode);
  XCTAssertEqualObjects([ZXQRCodeErrorCorrectionLevel errorCorrectionLevelH], qrCode.ecLevel);
  XCTAssertEqual(7, qrCode.version.versionNumber);
  XCTAssertEqual(3, qrCode.maskPattern);

  // Prepare the matrix.
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:45 height:45];
  // Just set bogus zero/one values.
  for (int y = 0; y < 45; ++y) {
    for (int x = 0; x < 45; ++x) {
      [matrix setX:x y:y intValue:(y + x) % 2];
    }
  }

  // Set the matrix.
  qrCode.matrix = matrix;
  XCTAssertEqualObjects(matrix, qrCode.matrix);
}

- (void)testToString1 {
  ZXQRCode *qrCode = [[ZXQRCode alloc] init];
  NSString *expected =
    @"<<\n"
     " mode: (null)\n"
     " ecLevel: (null)\n"
     " version: (null)\n"
     " maskPattern: -1\n"
     " matrix: (null)\n"
     ">>\n";
  XCTAssertEqualObjects(expected, [qrCode description]);
}

- (void)testToString2 {
  ZXQRCode *qrCode = [[ZXQRCode alloc] init];
  qrCode.mode = [ZXQRCodeMode byteMode];
  qrCode.ecLevel = [ZXQRCodeErrorCorrectionLevel errorCorrectionLevelH];
  qrCode.version = [ZXQRCodeVersion versionForNumber:1];
  qrCode.maskPattern = 3;
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:21 height:21];
  for (int y = 0; y < 21; ++y) {
    for (int x = 0; x < 21; ++x) {
      [matrix setX:x y:y intValue:(y + x) % 2];
    }
  }
  qrCode.matrix = matrix;
  NSString *expected =
    @"<<\n"
     " mode: BYTE\n"
     " ecLevel: H\n"
     " version: 1\n"
     " maskPattern: 3\n"
     " matrix:\n"
     " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n"
     " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n"
     " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n"
     " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n"
     " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n"
     " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n"
     " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n"
     " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n"
     " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n"
     " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n"
     " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n"
     " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n"
     " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n"
     " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n"
     " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n"
     " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n"
     " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n"
     " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n"
     " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n"
     " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n"
     " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n"
     ">>\n";
  XCTAssertEqualObjects(expected, [qrCode description]);
}

- (void)testIsValidMaskPattern {
  XCTAssertFalse([ZXQRCode isValidMaskPattern:-1]);
  XCTAssertTrue([ZXQRCode isValidMaskPattern:0]);
  XCTAssertTrue([ZXQRCode isValidMaskPattern:7]);
  XCTAssertFalse([ZXQRCode isValidMaskPattern:8]);
}

@end

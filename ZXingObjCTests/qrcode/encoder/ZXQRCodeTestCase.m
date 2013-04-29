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

#import "ZXByteMatrix.h"
#import "ZXErrorCorrectionLevel.h"
#import "ZXMode.h"
#import "ZXQRCode.h"
#import "ZXQRCodeTestCase.h"
#import "ZXQRCodeVersion.h"

@implementation ZXQRCodeTestCase

- (void)test {
  ZXQRCode *qrCode = [[ZXQRCode alloc] init];

  // First, test simple setters and getters.
  // We use numbers of version 7-H.
  qrCode.mode = [ZXMode byteMode];
  qrCode.ecLevel = [ZXErrorCorrectionLevel errorCorrectionLevelH];
  qrCode.version = [ZXQRCodeVersion versionForNumber:7];
  qrCode.maskPattern = 3;

  STAssertEqualObjects(qrCode.mode, [ZXMode byteMode], @"Expected qrCode mode to be byteMode");
  STAssertEqualObjects(qrCode.ecLevel, [ZXErrorCorrectionLevel errorCorrectionLevelH],
                       @"Expected qrCode error correction level to be H");
  STAssertEquals(qrCode.version.versionNumber, 7, @"Expected qrCode version to be 7");
  STAssertEquals(qrCode.maskPattern, 3, @"Expected qrCode maskPattern to be 3");

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
  STAssertEqualObjects(qrCode.matrix, matrix, @"Expected matrices to be equal");
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
  STAssertEqualObjects([qrCode description], expected, @"Expected qrCode to equal %@", expected);
}

- (void)testToString2 {
  ZXQRCode *qrCode = [[ZXQRCode alloc] init];
  qrCode.mode = [ZXMode byteMode];
  qrCode.ecLevel = [ZXErrorCorrectionLevel errorCorrectionLevelH];
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
  STAssertEqualObjects([qrCode description], expected, @"Expected qrCode to equal %@", expected);
}

- (void)testIsValidMaskPattern {
  STAssertFalse([ZXQRCode isValidMaskPattern:-1], @"Expected -1 not to be a valid mask pattern");
  STAssertTrue([ZXQRCode isValidMaskPattern:0], @"Expected 0 to be a valid mask pattern");
  STAssertTrue([ZXQRCode isValidMaskPattern:7], @"Expected 7 to be a valid mask pattern");
  STAssertFalse([ZXQRCode isValidMaskPattern:8], @"Expected 8 not to be a valid mask pattern");
}

@end

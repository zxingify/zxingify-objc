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

#import "ZXMatrixUtilTestCase.h"

@implementation ZXMatrixUtilTestCase

- (void)testToString {
  ZXByteMatrix *array = [[ZXByteMatrix alloc] initWithWidth:3 height:3];
  [array setX:0 y:0 intValue:0];
  [array setX:1 y:0 intValue:1];
  [array setX:2 y:0 intValue:0];
  [array setX:0 y:1 intValue:1];
  [array setX:1 y:1 intValue:0];
  [array setX:2 y:1 intValue:1];
  [array setX:0 y:2 intValue:-1];
  [array setX:1 y:2 intValue:-1];
  [array setX:2 y:2 intValue:-1];
  NSString *expected = @" 0 1 0\n 1 0 1\n      \n";
  XCTAssertEqualObjects(expected, [array description]);
}

- (void)testClearMatrix {
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:2 height:2];
  [ZXMatrixUtil clearMatrix:matrix];
  XCTAssertEqual(-1, [matrix getX:0 y:0]);
  XCTAssertEqual(-1, [matrix getX:1 y:0]);
  XCTAssertEqual(-1, [matrix getX:0 y:1]);
  XCTAssertEqual(-1, [matrix getX:1 y:1]);
}

- (void)testEmbedBasicPatterns1 {
  // Version 1.
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:21 height:21];
  [ZXMatrixUtil clearMatrix:matrix];
  [ZXMatrixUtil embedBasicPatterns:[ZXQRCodeVersion versionForNumber:1] matrix:matrix error:nil];
  NSString *expected =
    @" 1 1 1 1 1 1 1 0           0 1 1 1 1 1 1 1\n"
     " 1 0 0 0 0 0 1 0           0 1 0 0 0 0 0 1\n"
     " 1 0 1 1 1 0 1 0           0 1 0 1 1 1 0 1\n"
     " 1 0 1 1 1 0 1 0           0 1 0 1 1 1 0 1\n"
     " 1 0 1 1 1 0 1 0           0 1 0 1 1 1 0 1\n"
     " 1 0 0 0 0 0 1 0           0 1 0 0 0 0 0 1\n"
     " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
     " 0 0 0 0 0 0 0 0           0 0 0 0 0 0 0 0\n"
     "             1                            \n"
     "             0                            \n"
     "             1                            \n"
     "             0                            \n"
     "             1                            \n"
     " 0 0 0 0 0 0 0 0 1                        \n"
     " 1 1 1 1 1 1 1 0                          \n"
     " 1 0 0 0 0 0 1 0                          \n"
     " 1 0 1 1 1 0 1 0                          \n"
     " 1 0 1 1 1 0 1 0                          \n"
     " 1 0 1 1 1 0 1 0                          \n"
     " 1 0 0 0 0 0 1 0                          \n"
     " 1 1 1 1 1 1 1 0                          \n";
  XCTAssertEqualObjects(expected, [matrix description]);
}

- (void)testEmbedBasicPatterns2 {
  // Version 2.  Position adjustment pattern should apppear at right
  // bottom corner.
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:25 height:25];
  [ZXMatrixUtil clearMatrix:matrix];
  [ZXMatrixUtil embedBasicPatterns:[ZXQRCodeVersion versionForNumber:2] matrix:matrix error:nil];
  NSString *expected =
    @" 1 1 1 1 1 1 1 0                   0 1 1 1 1 1 1 1\n"
     " 1 0 0 0 0 0 1 0                   0 1 0 0 0 0 0 1\n"
     " 1 0 1 1 1 0 1 0                   0 1 0 1 1 1 0 1\n"
     " 1 0 1 1 1 0 1 0                   0 1 0 1 1 1 0 1\n"
     " 1 0 1 1 1 0 1 0                   0 1 0 1 1 1 0 1\n"
     " 1 0 0 0 0 0 1 0                   0 1 0 0 0 0 0 1\n"
     " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
     " 0 0 0 0 0 0 0 0                   0 0 0 0 0 0 0 0\n"
     "             1                                    \n"
     "             0                                    \n"
     "             1                                    \n"
     "             0                                    \n"
     "             1                                    \n"
     "             0                                    \n"
     "             1                                    \n"
     "             0                                    \n"
     "             1                   1 1 1 1 1        \n"
     " 0 0 0 0 0 0 0 0 1               1 0 0 0 1        \n"
     " 1 1 1 1 1 1 1 0                 1 0 1 0 1        \n"
     " 1 0 0 0 0 0 1 0                 1 0 0 0 1        \n"
     " 1 0 1 1 1 0 1 0                 1 1 1 1 1        \n"
     " 1 0 1 1 1 0 1 0                                  \n"
     " 1 0 1 1 1 0 1 0                                  \n"
     " 1 0 0 0 0 0 1 0                                  \n"
     " 1 1 1 1 1 1 1 0                                  \n";
  XCTAssertEqualObjects(expected, [matrix description]);
}

- (void)testEmbedTypeInfo {
  // Type info bits = 100000011001110.
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:21 height:21];
  [ZXMatrixUtil clearMatrix:matrix];
  [ZXMatrixUtil embedTypeInfo:[ZXErrorCorrectionLevel errorCorrectionLevelM] maskPattern:5 matrix:matrix error:nil];
  NSString *expected =
    @"                 0                        \n"
     "                 1                        \n"
     "                 1                        \n"
     "                 1                        \n"
     "                 0                        \n"
     "                 0                        \n"
     "                                          \n"
     "                 1                        \n"
     " 1 0 0 0 0 0   0 1         1 1 0 0 1 1 1 0\n"
     "                                          \n"
     "                                          \n"
     "                                          \n"
     "                                          \n"
     "                                          \n"
     "                 0                        \n"
     "                 0                        \n"
     "                 0                        \n"
     "                 0                        \n"
     "                 0                        \n"
     "                 0                        \n"
     "                 1                        \n";
  XCTAssertEqualObjects(expected, [matrix description]);
}

- (void)testEmbedVersionInfo {
  // Version info bits = 000111 110010 010100
  // Actually, version 7 QR Code has 45x45 matrix but we use 21x21 here
  // since 45x45 matrix is too big to depict.
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:21 height:21];
  [ZXMatrixUtil clearMatrix:matrix];
  [ZXMatrixUtil maybeEmbedVersionInfo:[ZXQRCodeVersion versionForNumber:7] matrix:matrix error:nil];
  NSString *expected =
    @"                     0 0 1                \n"
     "                     0 1 0                \n"
     "                     0 1 0                \n"
     "                     0 1 1                \n"
     "                     1 1 1                \n"
     "                     0 0 0                \n"
     "                                          \n"
     "                                          \n"
     "                                          \n"
     "                                          \n"
     " 0 0 0 0 1 0                              \n"
     " 0 1 1 1 1 0                              \n"
     " 1 0 0 1 1 0                              \n"
     "                                          \n"
     "                                          \n"
     "                                          \n"
     "                                          \n"
     "                                          \n"
     "                                          \n"
     "                                          \n"
     "                                          \n";
  XCTAssertEqualObjects(expected, [matrix description]);
}

- (void)testEmbedDataBits {
  // Cells other than basic patterns should be filled with zero.
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:21 height:21];
  [ZXMatrixUtil clearMatrix:matrix];
  [ZXMatrixUtil embedBasicPatterns:[ZXQRCodeVersion versionForNumber:1] matrix:matrix error:nil];
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXMatrixUtil embedDataBits:bits maskPattern:-1 matrix:matrix error:nil];
  NSString *expected =
    @" 1 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 1\n"
     " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 1\n"
     " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1 0 1\n"
     " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1 0 1\n"
     " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1 0 1\n"
     " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 1\n"
     " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
     " 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
     " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n";
  XCTAssertEqualObjects(expected, [matrix description]);
}

- (void)testBuildMatrix {
  // From http://www.swetake.com/qr/qr7.html
  const int bytesLen = 26;
  int8_t bytes[bytesLen] = {32, 65, 205, 69, 41, 220, 46, 128, 236,
    42, 159, 74, 221, 244, 169, 239, 150, 138,
    70, 237, 85, 224, 96, 74, 219, 61};
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  for (int i = 0; i < bytesLen; i++) {
    [bits appendBits:bytes[i] numBits:8];
  }
  ZXByteMatrix *matrix = [[ZXByteMatrix alloc] initWithWidth:21 height:21];
  [ZXMatrixUtil buildMatrix:bits
                    ecLevel:[ZXErrorCorrectionLevel errorCorrectionLevelH]
                    version:[ZXQRCodeVersion versionForNumber:1]
                maskPattern:3  // Mask pattern 3
                     matrix:matrix
                      error:nil];
  NSString *expected =
    @" 1 1 1 1 1 1 1 0 0 1 1 0 0 0 1 1 1 1 1 1 1\n"
     " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 1\n"
     " 1 0 1 1 1 0 1 0 0 0 0 1 0 0 1 0 1 1 1 0 1\n"
     " 1 0 1 1 1 0 1 0 0 1 1 0 0 0 1 0 1 1 1 0 1\n"
     " 1 0 1 1 1 0 1 0 1 1 0 0 1 0 1 0 1 1 1 0 1\n"
     " 1 0 0 0 0 0 1 0 0 0 1 1 1 0 1 0 0 0 0 0 1\n"
     " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
     " 0 0 0 0 0 0 0 0 1 1 0 1 1 0 0 0 0 0 0 0 0\n"
     " 0 0 1 1 0 0 1 1 1 0 0 1 1 1 1 0 1 0 0 0 0\n"
     " 1 0 1 0 1 0 0 0 0 0 1 1 1 0 0 1 0 1 1 1 0\n"
     " 1 1 1 1 0 1 1 0 1 0 1 1 1 0 0 1 1 1 0 1 0\n"
     " 1 0 1 0 1 1 0 1 1 1 0 0 1 1 1 0 0 1 0 1 0\n"
     " 0 0 1 0 0 1 1 1 0 0 0 0 0 0 1 0 1 1 1 1 1\n"
     " 0 0 0 0 0 0 0 0 1 1 0 1 0 0 0 0 0 1 0 1 1\n"
     " 1 1 1 1 1 1 1 0 1 1 1 1 0 0 0 0 1 0 1 1 0\n"
     " 1 0 0 0 0 0 1 0 0 0 0 1 0 1 1 1 0 0 0 0 0\n"
     " 1 0 1 1 1 0 1 0 0 1 0 0 1 1 0 0 1 0 0 1 1\n"
     " 1 0 1 1 1 0 1 0 1 1 0 1 0 0 0 0 0 1 1 1 0\n"
     " 1 0 1 1 1 0 1 0 1 1 1 1 0 0 0 0 1 1 1 0 0\n"
     " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 1 0 0\n"
     " 1 1 1 1 1 1 1 0 0 0 1 1 1 1 1 0 1 0 0 1 0\n";
  XCTAssertEqualObjects(expected, [matrix description]);
}

- (void)testFindMSBSet {
  XCTAssertEqual(0, [ZXMatrixUtil findMSBSet:0]);
  XCTAssertEqual(1, [ZXMatrixUtil findMSBSet:1]);
  XCTAssertEqual(8, [ZXMatrixUtil findMSBSet:0x80]);
  XCTAssertEqual(32, [ZXMatrixUtil findMSBSet:0x80000000]);
}

- (void)testCalculateBCHCode {
  // Encoding of type information.
  // From Appendix C in JISX0510:2004 (p 65)
  XCTAssertEqual(0xdc, [ZXMatrixUtil calculateBCHCode:5 poly:0x537]);
  // From http://www.swetake.com/qr/qr6.html
  XCTAssertEqual(0x1c2, [ZXMatrixUtil calculateBCHCode:0x13 poly:0x537]);
  // From http://www.swetake.com/qr/qr11.html
  XCTAssertEqual(0x214, [ZXMatrixUtil calculateBCHCode:0x1b poly:0x537]);

  // Encofing of version information.
  // From Appendix D in JISX0510:2004 (p 68)
  XCTAssertEqual(0xc94, [ZXMatrixUtil calculateBCHCode:7 poly:0x1f25]);
  XCTAssertEqual(0x5bc, [ZXMatrixUtil calculateBCHCode:8 poly:0x1f25]);
  XCTAssertEqual(0xa99, [ZXMatrixUtil calculateBCHCode:9 poly:0x1f25]);
  XCTAssertEqual(0x4d3, [ZXMatrixUtil calculateBCHCode:10 poly:0x1f25]);
  XCTAssertEqual(0x9a6, [ZXMatrixUtil calculateBCHCode:20 poly:0x1f25]);
  XCTAssertEqual(0xd75, [ZXMatrixUtil calculateBCHCode:30 poly:0x1f25]);
  XCTAssertEqual(0xc69, [ZXMatrixUtil calculateBCHCode:40 poly:0x1f25]);
}

// We don't test a lot of cases in this function since we've already
// tested them in TEST(calculateBCHCode).
- (void)testMakeVersionInfoBits {
  // From Appendix D in JISX0510:2004 (p 68)
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXMatrixUtil makeVersionInfoBits:[ZXQRCodeVersion versionForNumber:7] bits:bits error:nil];
  XCTAssertEqualObjects(@" ...XXXXX ..X..X.X ..", [bits description]);
}

// We don't test a lot of cases in this function since we've already
// tested them in TEST(calculateBCHCode).
- (void)testMakeTypeInfoInfoBits {
  // From Appendix C in JISX0510:2004 (p 65)
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXMatrixUtil makeTypeInfoBits:[ZXErrorCorrectionLevel errorCorrectionLevelM] maskPattern:5 bits:bits error:nil];
  XCTAssertEqualObjects(@" X......X X..XXX.", [bits description]);
}

@end

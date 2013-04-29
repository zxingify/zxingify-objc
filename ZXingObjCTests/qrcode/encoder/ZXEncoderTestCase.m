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

#import "ZXBitArray.h"
#import "ZXEncodeHints.h"
#import "ZXEncoder.h"
#import "ZXEncoderTestCase.h"
#import "ZXErrorCorrectionLevel.h"
#import "ZXErrors.h"
#import "ZXMode.h"
#import "ZXQRCode.h"
#import "ZXQRCodeVersion.h"

@interface ZXEncoderTestCase ()

- (NSString *)shiftJISString:(unsigned char *)bytes bytesLen:(int)bytesLen;

@end

@implementation ZXEncoderTestCase

- (void)testGetAlphanumericCode {
  // The first ten code points are numbers.
  for (int i = 0; i < 10; ++i) {
    STAssertEquals([ZXEncoder alphanumericCode:'0' + i], i, @"Expected %d", i);
  }

  // The next 26 code points are capital alphabet letters.
  for (int i = 10; i < 36; ++i) {
    STAssertEquals([ZXEncoder alphanumericCode:'A' + i - 10], i, @"Expected %d", i);
  }

  // Others are symbol letters
  STAssertEquals([ZXEncoder alphanumericCode:' '], 36, @"Expected %d", 36);
  STAssertEquals([ZXEncoder alphanumericCode:'$'], 37, @"Expected %d", 37);
  STAssertEquals([ZXEncoder alphanumericCode:'%'], 38, @"Expected %d", 38);
  STAssertEquals([ZXEncoder alphanumericCode:'*'], 39, @"Expected %d", 39);
  STAssertEquals([ZXEncoder alphanumericCode:'+'], 40, @"Expected %d", 40);
  STAssertEquals([ZXEncoder alphanumericCode:'-'], 41, @"Expected %d", 41);
  STAssertEquals([ZXEncoder alphanumericCode:'.'], 42, @"Expected %d", 42);
  STAssertEquals([ZXEncoder alphanumericCode:'/'], 43, @"Expected %d", 43);
  STAssertEquals([ZXEncoder alphanumericCode:':'], 44, @"Expected %d", 44);

  // Should return -1 for other letters;
  STAssertEquals([ZXEncoder alphanumericCode:'a'], -1, @"Expected -1");
  STAssertEquals([ZXEncoder alphanumericCode:'#'], -1, @"Expected -1");
  STAssertEquals([ZXEncoder alphanumericCode:'\0'], -1, @"Expected -1");
}

- (void)testChooseMode {
  // Numeric mode.
  STAssertEqualObjects([ZXEncoder chooseMode:@"0"], [ZXMode numericMode], @"Expected numeric mode");
  STAssertEqualObjects([ZXEncoder chooseMode:@"0123456789"], [ZXMode numericMode], @"Expected numeric mode");
  // Alphanumeric mode.
  STAssertEqualObjects([ZXEncoder chooseMode:@"A"], [ZXMode alphanumericMode], @"Expected alphanumeric mode");
  STAssertEqualObjects([ZXEncoder chooseMode:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"],
                       [ZXMode alphanumericMode], @"Expected alphanumeric mode");
  // 8-bit byte mode.
  STAssertEqualObjects([ZXEncoder chooseMode:@"a"], [ZXMode byteMode], @"Expected byte mode");
  STAssertEqualObjects([ZXEncoder chooseMode:@"#"], [ZXMode byteMode], @"Expected byte mode");
  STAssertEqualObjects([ZXEncoder chooseMode:@""], [ZXMode byteMode], @"Expected byte mode");
  // Kanji mode.  We used to use MODE_KANJI for these, but we stopped
  // doing that as we cannot distinguish Shift_JIS from other encodings
  // from data bytes alone.  See also comments in qrcode_encoder.h.

  // AIUE in Hiragana in Shift_JIS
  unsigned char hiraganaBytes[8] = {0x8, 0xa, 0x8, 0xa, 0x8, 0xa, 0x8, 0xa6};
  STAssertEqualObjects([ZXEncoder chooseMode:[self shiftJISString:hiraganaBytes bytesLen:8]], [ZXMode byteMode],
                       @"Expected byte mode");

  // Nihon in Kanji in Shift_JIS.
  unsigned char kanjiBytes[4] = {0x9, 0xf, 0x9, 0x7b};
  STAssertEqualObjects([ZXEncoder chooseMode:[self shiftJISString:kanjiBytes bytesLen:4]], [ZXMode byteMode],
                       @"Expected byte mode");

  // Sou-Utsu-Byou in Kanji in Shift_JIS.
  unsigned char kanjiBytes2[6] = {0xe, 0x4, 0x9, 0x5, 0x9, 0x61};
  STAssertEqualObjects([ZXEncoder chooseMode:[self shiftJISString:kanjiBytes2 bytesLen:6]], [ZXMode byteMode],
                       @"Expected byte mode");
}

- (void)testEncode {
  ZXQRCode *qrCode = [ZXEncoder encode:@"ABCDEF" ecLevel:[ZXErrorCorrectionLevel errorCorrectionLevelH] error:nil];
  // The following is a valid QR Code that can be read by cell phones.
  NSString *expected =
    @"<<\n"
    " mode: ALPHANUMERIC\n"
    " ecLevel: H\n"
    " version: 1\n"
    " maskPattern: 0\n"
    " matrix:\n"
    " 1 1 1 1 1 1 1 0 1 1 1 1 0 0 1 1 1 1 1 1 1\n"
    " 1 0 0 0 0 0 1 0 0 1 1 1 0 0 1 0 0 0 0 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 0 1 1 0 1 0 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 1 1 1 0 1 0 1 0 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 1 1 0 0 1 0 1 1 1 0 1\n"
    " 1 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 1\n"
    " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
    " 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0\n"
    " 0 0 1 0 1 1 1 0 1 1 0 0 1 1 0 0 0 1 0 0 1\n"
    " 1 0 1 1 1 0 0 1 0 0 0 1 0 1 0 0 0 0 0 0 0\n"
    " 0 0 1 1 0 0 1 0 1 0 0 0 1 0 1 0 1 0 1 1 0\n"
    " 1 1 0 1 0 1 0 1 1 1 0 1 0 1 0 0 0 0 0 1 0\n"
    " 0 0 1 1 0 1 1 1 1 0 0 0 1 0 1 0 1 1 1 1 0\n"
    " 0 0 0 0 0 0 0 0 1 0 0 1 1 1 0 1 0 1 0 0 0\n"
    " 1 1 1 1 1 1 1 0 0 0 1 0 1 0 1 1 0 0 0 0 1\n"
    " 1 0 0 0 0 0 1 0 1 1 1 1 0 1 0 1 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 1 0 1 1 0 1 0 1 0 0 0 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 1 0 1 1 1 1 0 1 0 1 0\n"
    " 1 0 1 1 1 0 1 0 1 0 0 0 1 0 1 0 1 1 1 0 1\n"
    " 1 0 0 0 0 0 1 0 0 1 1 0 1 1 0 1 0 0 0 1 1\n"
    " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 1 0 1 0 1\n"
    ">>\n";
  STAssertEqualObjects([qrCode description], expected, @"Expected qr code to equal %@", expected);
}

- (void)testSimpleUTF8ECI {
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.encoding = NSUTF8StringEncoding;
  ZXQRCode *qrCode = [ZXEncoder encode:@"hello" ecLevel:[ZXErrorCorrectionLevel errorCorrectionLevelH] hints:hints error:nil];
  NSString *expected =
    @"<<\n"
    " mode: BYTE\n"
    " ecLevel: H\n"
    " version: 1\n"
    " maskPattern: 3\n"
    " matrix:\n"
    " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 1\n"
    " 1 0 0 0 0 0 1 0 0 0 1 0 1 0 1 0 0 0 0 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 0 1 0 0 1 0 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 1 0 1 0 1 0 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 0 1\n"
    " 1 0 0 0 0 0 1 0 0 0 0 0 1 0 1 0 0 0 0 0 1\n"
    " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n"
    " 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0\n"
    " 0 0 1 1 0 0 1 1 1 1 0 0 0 1 1 0 1 0 0 0 0\n"
    " 0 0 1 1 1 0 0 0 0 0 1 1 0 0 0 1 0 1 1 1 0\n"
    " 0 1 0 1 0 1 1 1 0 1 0 1 0 0 0 0 0 1 1 1 1\n"
    " 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 0 1 0 1 1 0\n"
    " 0 0 0 0 1 0 1 1 1 1 0 0 0 0 0 1 0 0 1 0 0\n"
    " 0 0 0 0 0 0 0 0 1 1 1 1 0 0 1 1 1 0 0 0 1\n"
    " 1 1 1 1 1 1 1 0 1 1 1 0 1 0 1 1 0 0 1 0 0\n"
    " 1 0 0 0 0 0 1 0 0 0 1 0 0 1 1 1 1 1 1 0 1\n"
    " 1 0 1 1 1 0 1 0 0 1 0 0 0 0 1 1 0 0 0 0 0\n"
    " 1 0 1 1 1 0 1 0 1 1 1 0 1 0 0 0 1 1 0 0 0\n"
    " 1 0 1 1 1 0 1 0 1 1 0 0 0 1 0 0 1 0 0 0 0\n"
    " 1 0 0 0 0 0 1 0 0 0 0 1 1 0 1 0 1 0 1 1 0\n"
    " 1 1 1 1 1 1 1 0 0 1 0 1 1 1 0 1 1 0 0 0 0\n"
    ">>\n";
  STAssertEqualObjects([qrCode description], expected, @"Expected qr code to equal %@", expected);
}

- (void)testAppendModeInfo {
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  [ZXEncoder appendModeInfo:[ZXMode numericMode] bits:bits];
  NSString *expected = @" ...X";
  STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
}

- (void)testAppendLengthInfo {
  {
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendLengthInfo:1  // 1 letter (1/1).
                        version:[ZXQRCodeVersion versionForNumber:1]
                           mode:[ZXMode numericMode]
                           bits:bits
                          error:nil];
    NSString *expected = @" ........ .X";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);  // 10 bits.
  }
  {
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendLengthInfo:2  // 2 letter (2/1).
                        version:[ZXQRCodeVersion versionForNumber:10]
                           mode:[ZXMode alphanumericMode]
                           bits:bits
                          error:nil];
    NSString *expected = @" ........ .X.";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);  // 11 bits.
  }
  {
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendLengthInfo:255  // 255 letter (255/1).
                        version:[ZXQRCodeVersion versionForNumber:27]
                           mode:[ZXMode byteMode]
                           bits:bits
                          error:nil];
    NSString *expected = @" ........ XXXXXXXX";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);  // 16 bits.
  }
  {
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendLengthInfo:512  // 512 letter (1024/2).
                        version:[ZXQRCodeVersion versionForNumber:40]
                           mode:[ZXMode kanjiMode]
                           bits:bits
                          error:nil];
    NSString *expected = @" ..X..... ....";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);  // 12 bits.
  }
}

- (void)testAppendBytes {
  {
    // Should use appendNumericBytes.
    // 1 = 01 = 0001 in 4 bits.
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendBytes:@"1" mode:[ZXMode numericMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:nil];
    NSString *expected = @" ...X";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  }
  {
    // Should use appendAlphanumericBytes.
    // A = 10 = 0xa = 001010 in 6 bits
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendBytes:@"A" mode:[ZXMode alphanumericMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:nil];
    NSString *expected = @" ..X.X.";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
    // Lower letters such as 'a' cannot be encoded in MODE_ALPHANUMERIC.
    NSError *error;
    if ([ZXEncoder appendBytes:@"a" mode:[ZXMode alphanumericMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:&error] ||
        error.code != ZXWriterError) {
      STFail(@"Expected ZXWriterError");
    }
  }
  {
    // Should use append8BitBytes.
    // 0x61, 0x62, 0x63
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendBytes:@"abc" mode:[ZXMode byteMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:nil];
    NSString *expected = @" .XX....X .XX...X. .XX...XX";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
    // Anything can be encoded in QRCode.MODE_8BIT_BYTE.
    [ZXEncoder appendBytes:@"\0" mode:[ZXMode byteMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:nil];
  }
  {
    // Should use appendKanjiBytes.
    // 0x93, 0x5f
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    unsigned char bytes[2] = {0x93, 0x5f};
    [ZXEncoder appendBytes:[self shiftJISString:bytes bytesLen:2] mode:[ZXMode kanjiMode] bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING error:nil];
    NSString *expected = @" .XX.XX.. XXXXX";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  }
}

- (void)testTerminateBits {
  {
    ZXBitArray *v = [[ZXBitArray alloc] init];
    [ZXEncoder terminateBits:0 bits:v error:nil];
    STAssertEqualObjects([v description], @"", @"Expected v to equal \"\"");
  }
  {
    ZXBitArray *v = [[ZXBitArray alloc] init];
    [ZXEncoder terminateBits:1 bits:v error:nil];
    NSString *expected = @" ........";
    STAssertEqualObjects([v description], expected, @"Expected v to equal %@");
  }
  {
    ZXBitArray *v = [[ZXBitArray alloc] init];
    [v appendBits:0 numBits:3];  // Append 000
    [ZXEncoder terminateBits:1 bits:v error:nil];
    NSString *expected = @" ........";
    STAssertEqualObjects([v description], expected, @"Expected v to equal %@");
  }
  {
    ZXBitArray *v = [[ZXBitArray alloc] init];
    [v appendBits:0 numBits:5];  // Append 00000
    [ZXEncoder terminateBits:1 bits:v error:nil];
    NSString *expected = @" ........";
    STAssertEqualObjects([v description], expected, @"Expected v to equal %@");
  }
  {
    ZXBitArray *v = [[ZXBitArray alloc] init];
    [v appendBits:0 numBits:8];  // Append 00000000
    [ZXEncoder terminateBits:1 bits:v error:nil];
    NSString *expected = @" ........";
    STAssertEqualObjects([v description], expected, @"Expected v to equal %@");
  }
  {
    ZXBitArray *v = [[ZXBitArray alloc] init];
    [ZXEncoder terminateBits:2 bits:v error:nil];
    NSString *expected = @" ........ XXX.XX..";
    STAssertEqualObjects([v description], expected, @"Expected v to equal %@");
  }
  {
    ZXBitArray *v = [[ZXBitArray alloc] init];
    [v appendBits:0 numBits:1];  // Append 0
    [ZXEncoder terminateBits:3 bits:v error:nil];
    NSString *expected = @" ........ XXX.XX.. ...X...X";
    STAssertEqualObjects([v description], expected, @"Expected v to equal %@");
  }
}

- (void)testGetNumDataBytesAndNumECBytesForBlockID {
  int numDataBytes[1] = {0};
  int numEcBytes[1] = {0};
  // Version 1-H.
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:26 numDataBytes:9 numRSBlocks:1 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  STAssertEquals(numDataBytes[0], 9, @"Expected numDataBytes[0] to equal %d", 9);
  STAssertEquals(numEcBytes[0], 17, @"Expected numEcBytes[0] to equal %d", 17);

  // Version 3-H.  2 blocks.
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:70 numDataBytes:26 numRSBlocks:2 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  STAssertEquals(numDataBytes[0], 13, @"Expected numDataBytes[0] to equal %d", 13);
  STAssertEquals(numEcBytes[0], 22, @"Expected numEcBytes[0] to equal %d", 22);
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:70 numDataBytes:26 numRSBlocks:2 blockID:1
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  STAssertEquals(numDataBytes[0], 13, @"Expected numDataBytes[0] to equal %d", 13);
  STAssertEquals(numEcBytes[0], 22, @"Expected numEcBytes[0] to equal %d", 22);

  // Version 7-H. (4 + 1) blocks.
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:196 numDataBytes:66 numRSBlocks:5 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  STAssertEquals(numDataBytes[0], 13, @"Expected numDataBytes[0] to equal %d", 13);
  STAssertEquals(numEcBytes[0], 26, @"Expected numEcBytes[0] to equal %d", 26);
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:196 numDataBytes:66 numRSBlocks:5 blockID:4
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  STAssertEquals(numDataBytes[0], 14, @"Expected numDataBytes[0] to equal %d", 14);
  STAssertEquals(numEcBytes[0], 26, @"Expected numEcBytes[0] to equal %d", 22);

  // Version 40-H. (20 + 61) blocks.
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:3706 numDataBytes:1276 numRSBlocks:81 blockID:0
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  STAssertEquals(numDataBytes[0], 15, @"Expected numDataBytes[0] to equal %d", 15);
  STAssertEquals(numEcBytes[0], 30, @"Expected numEcBytes[0] to equal %d", 30);
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:3706 numDataBytes:1276 numRSBlocks:81 blockID:20
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  STAssertEquals(numDataBytes[0], 16, @"Expected numDataBytes[0] to equal %d", 16);
  STAssertEquals(numEcBytes[0], 30, @"Expected numEcBytes[0] to equal %d", 30);
  [ZXEncoder numDataBytesAndNumECBytesForBlockID:3706 numDataBytes:1276 numRSBlocks:81 blockID:80
                             numDataBytesInBlock:numDataBytes numECBytesInBlock:numEcBytes error:nil];
  STAssertEquals(numDataBytes[0], 16, @"Expected numDataBytes[0] to equal %d", 16);
  STAssertEquals(numEcBytes[0], 30, @"Expected numEcBytes[0] to equal %d", 30);
}

- (void)testInterleaveWithECBytes {
  {
    const int dataBytesLen = 9;
    unsigned char dataBytes[dataBytesLen] = {32, 65, 205, 69, 41, 220, 46, 128, 236};
    ZXBitArray *in = [[ZXBitArray alloc] init];
    for (int i = 0; i < dataBytesLen; i++) {
      [in appendBits:dataBytes[i] numBits:8];
    }
    ZXBitArray *out = [ZXEncoder interleaveWithECBytes:in numTotalBytes:26 numDataBytes:9 numRSBlocks:1 error:nil];
    const int expectedLen = 26;
    unsigned char expected[expectedLen] = {
      // Data bytes.
      32, 65, 205, 69, 41, 220, 46, 128, 236,
      // Error correction bytes.
      42, 159, 74, 221, 244, 169, 239, 150, 138, 70,
      237, 85, 224, 96, 74, 219, 61,
    };
    STAssertEquals(out.sizeInBytes, expectedLen, @"Expected out sizeInBytes to equal %d", expectedLen);
    unsigned char outArray[expectedLen];
    memset(outArray, 0, expectedLen * sizeof(unsigned char));
    [out toBytes:0 array:outArray offset:0 numBytes:expectedLen];
    for (int x = 0; x < expectedLen; x++) {
      STAssertEquals(outArray[x], expected[x], @"Expected outArray[%d] to equal %d", x, expected[x]);
    }
  }
  // Numbers are from http://www.swetake.com/qr/qr8.html
  {
    const int dataBytesLen = 62;
    unsigned char dataBytes[dataBytesLen] = {
      67, 70, 22, 38, 54, 70, 86, 102, 118, 134, 150, 166, 182,
      198, 214, 230, 247, 7, 23, 39, 55, 71, 87, 103, 119, 135,
      151, 166, 22, 38, 54, 70, 86, 102, 118, 134, 150, 166,
      182, 198, 214, 230, 247, 7, 23, 39, 55, 71, 87, 103, 119,
      135, 151, 160, 236, 17, 236, 17, 236, 17, 236,
      17
    };
    ZXBitArray *in = [[ZXBitArray alloc] init];
    for (int i = 0; i < dataBytesLen; i++) {
      [in appendBits:dataBytes[i] numBits:8];
    }
    ZXBitArray *out = [ZXEncoder interleaveWithECBytes:in numTotalBytes:134 numDataBytes:62 numRSBlocks:4 error:nil];
    const int expectedLen = 134;
    unsigned char expected[expectedLen] = {
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
      187, 49, 156, 214,
    };
    STAssertEquals(out.sizeInBytes, expectedLen, @"Expected out sizeInBytes to equal %d", expectedLen);
    unsigned char outArray[expectedLen];
    memset(outArray, 0, expectedLen * sizeof(unsigned char));
    [out toBytes:0 array:outArray offset:0 numBytes:expectedLen];
    for (int x = 0; x < expectedLen; x++) {
      STAssertEquals(outArray[x], expected[x], @"Expected outArray[%d] to equal %d", x, expected[x]);
    }
  }
}

- (void)testAppendNumericBytes {
  {
    // 1 = 01 = 0001 in 4 bits.
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendNumericBytes:@"1" bits:bits];
    NSString *expected = @" ...X";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  }
  {
    // 12 = 0xc = 0001100 in 7 bits.
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendNumericBytes:@"12" bits:bits];
    NSString *expected = @" ...XX..";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  }
  {
    // 123 = 0x7b = 0001111011 in 10 bits.
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendNumericBytes:@"123" bits:bits];
    NSString *expected = @" ...XXXX. XX";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  }
  {
    // 1234 = "123" + "4" = 0001111011 + 0100
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendNumericBytes:@"1234" bits:bits];
    NSString *expected = @" ...XXXX. XX.X..";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  }
  {
    // Empty.
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendNumericBytes:@"" bits:bits];
    STAssertEqualObjects([bits description], @"", @"Expected bits to equal \"\"");
  }
}

- (void)testAppendAlphanumericBytes {
  {
    // A = 10 = 0xa = 001010 in 6 bits
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendAlphanumericBytes:@"A" bits:bits error:nil];
    NSString *expected = @" ..X.X.";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  }
  {
    // AB = 10 * 45 + 11 = 461 = 0x1cd = 00111001101 in 11 bits
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendAlphanumericBytes:@"AB" bits:bits error:nil];
    NSString *expected = @" ..XXX..X X.X";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  }
  {
    // ABC = "AB" + "C" = 00111001101 + 001100
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendAlphanumericBytes:@"ABC" bits:bits error:nil];
    NSString *expected = @" ..XXX..X X.X..XX. .";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  }
  {
    // Empty.
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder appendAlphanumericBytes:@"" bits:bits error:nil];
    STAssertEqualObjects([bits description], @"", @"Expected bits to equal \"\"");
  }
  {
    // Invalid data.
    NSError *error;
    if ([ZXEncoder appendAlphanumericBytes:@"abc" bits:[[ZXBitArray alloc] init] error:&error] || error.code != ZXWriterError) {
      STFail(@"Expected ZXWriterError");
    }
  }
}

- (void)testAppend8BitBytes {
  {
    // 0x61, 0x62, 0x63
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder append8BitBytes:@"abc" bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING];
    NSString *expected = @" .XX....X .XX...X. .XX...XX";
    STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  }
  {
    // Empty.
    ZXBitArray *bits = [[ZXBitArray alloc] init];
    [ZXEncoder append8BitBytes:@"" bits:bits encoding:DEFAULT_BYTE_MODE_ENCODING];
    STAssertEqualObjects([bits description], @"", @"Expected bits to equal \"\"");
  }
}

// Numbers are from page 21 of JISX0510:2004
- (void)testAppendKanjiBytes {
  ZXBitArray *bits = [[ZXBitArray alloc] init];
  unsigned char bytes[2] = {0x93,0x5f};
  [ZXEncoder appendKanjiBytes:[self shiftJISString:bytes bytesLen:2] bits:bits error:nil];
  NSString *expected = @" .XX.XX.. XXXXX";
  STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
  unsigned char bytes2[2] = {0xe4,0xaa};
  [ZXEncoder appendKanjiBytes:[self shiftJISString:bytes2 bytesLen:2] bits:bits error:nil];
  expected = @" .XX.XX.. XXXXXXX. X.X.X.X. X.";
  STAssertEqualObjects([bits description], expected, @"Expected bits to equal %@", expected);
}

// Numbers are from http://www.swetake.com/qr/qr3.html and
// http://www.swetake.com/qr/qr9.html
- (void)testGenerateECBytes {
  {
    const int dataBytesLen = 9;
    unsigned char dataBytes[dataBytesLen] = {32, 65, 205, 69, 41, 220, 46, 128, 236};
    unsigned char *ecBytes = [ZXEncoder generateECBytes:dataBytes numDataBytes:dataBytesLen numEcBytesInBlock:17];
    const int expectedLen = 17;
    int expected[expectedLen] = {
      42, 159, 74, 221, 244, 169, 239, 150, 138, 70, 237, 85, 224, 96, 74, 219, 61
    };
    for (int x = 0; x < expectedLen; x++) {
      STAssertEquals(ecBytes[x] & 0xFF, expected[x], @"Expected exBytes[%d] to equal %d", x, expected[x]);
    }
    free(ecBytes);
  }
  {
    const int dataBytesLen = 15;
    unsigned char dataBytes[dataBytesLen] = {67, 70, 22, 38, 54, 70, 86, 102, 118,
      134, 150, 166, 182, 198, 214};
    unsigned char *ecBytes = [ZXEncoder generateECBytes:dataBytes numDataBytes:dataBytesLen numEcBytesInBlock:18];
    const int expectedLen = 18;
    int expected[expectedLen] = {
      175, 80, 155, 64, 178, 45, 214, 233, 65, 209, 12, 155, 117, 31, 140, 214, 27, 187
    };
    for (int x = 0; x < expectedLen; x++) {
      STAssertEquals(ecBytes[x] & 0xFF, expected[x], @"Expected exBytes[%d] to equal %d", x, expected[x]);
    }
    free(ecBytes);
  }
  {
    // High-order zero coefficient case.
    const int dataBytesLen = 9;
    unsigned char dataBytes[dataBytesLen] = {32, 49, 205, 69, 42, 20, 0, 236, 17};
    unsigned char *ecBytes = [ZXEncoder generateECBytes:dataBytes numDataBytes:dataBytesLen numEcBytesInBlock:17];
    const int expectedLen = 17;
    int expected[expectedLen] = {
      0, 3, 130, 179, 194, 0, 55, 211, 110, 79, 98, 72, 170, 96, 211, 137, 213
    };
    for (int x = 0; x < expectedLen; x++) {
      STAssertEquals(ecBytes[x] & 0xFF, expected[x], @"Expected exBytes[%d] to equal %d", x, expected[x]);
    }
    free(ecBytes);
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
  ZXQRCode *qrCode = [ZXEncoder encode:builder ecLevel:[ZXErrorCorrectionLevel errorCorrectionLevelL] error:nil];
  STAssertNotNil(qrCode, @"Excepted QR code");
}

- (NSString *)shiftJISString:(unsigned char *)bytes bytesLen:(int)bytesLen {
  return [[NSString alloc] initWithBytes:bytes length:bytesLen encoding:NSShiftJISStringEncoding];
}

@end

/*
 * Copyright 2013 ZXing authors
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

#import "ZXAztecCode.h"
#import "ZXAztecDecoder.h"
#import "ZXAztecDetectorResult.h"
#import "ZXAztecEncoder.h"
#import "ZXAztecEncoderTest.h"
#import "ZXBitArray.h"
#import "ZXBitMatrix.h"
#import "ZXDecoderResult.h"

@interface ZXAztecEncoderTest ()

- (void)testEncode:(NSString *)data compact:(BOOL)compact layers:(int)layers expected:(NSString *)expected;
- (void)testEncodeDecode:(NSString *)data compact:(BOOL)compact layers:(int)layers;
- (void)testModeMessageCompact:(BOOL)compact layers:(int)layers words:(int)words expected:(NSString *)expected;
- (void)testStuffBits:(int)wordSize bits:(NSString *)bits expected:(NSString *)expected;
- (void)testHighLevelEncodeString:(NSString *)s expectedBits:(NSString *)expectedBits;
- (ZXBitArray *)toBitArray:(NSString *)bits;

@end

@implementation ZXAztecEncoderTest

// real life tests

- (void)testEncode1 {
  [self testEncode:@"This is an example Aztec symbol for Wikipedia." compact:YES layers:3
          expected:
   @"X     X X       X     X X     X     X         \n"
    "X         X     X X     X   X X   X X       X \n"
    "X X   X X X X X   X X X                 X     \n"
    "X X                 X X   X       X X X X X X \n"
    "    X X X   X   X     X X X X         X X     \n"
    "  X X X   X X X X   X     X   X     X X   X   \n"
    "        X X X X X     X X X X   X   X     X   \n"
    "X       X   X X X X X X X X X X X     X   X X \n"
    "X   X     X X X               X X X X   X X   \n"
    "X     X X   X X   X X X X X   X X   X   X X X \n"
    "X   X         X   X       X   X X X X       X \n"
    "X       X     X   X   X   X   X   X X   X     \n"
    "      X   X X X   X       X   X     X X X     \n"
    "    X X X X X X   X X X X X   X X X X X X   X \n"
    "  X X   X   X X               X X X   X X X X \n"
    "  X   X       X X X X X X X X X X X X   X X   \n"
    "  X X   X       X X X   X X X       X X       \n"
    "  X               X   X X     X     X X X     \n"
    "  X   X X X   X X   X   X X X X   X   X X X X \n"
    "    X   X   X X X   X   X   X X X X     X     \n"
    "        X               X                 X   \n"
    "        X X     X   X X   X   X   X       X X \n"
    "  X   X   X X       X   X         X X X     X \n"];
}

- (void)testEncode2 {
  [self testEncode:
   @"Aztec Code is a public domain 2D matrix barcode symbology"
    " of nominally square symbols built on a square grid with a "
    "distinctive square bullseye pattern at their center."
           compact:NO layers:6 expected:
   @"        X X     X X     X     X     X   X X X         X   X         X   X X       \n"
    "  X       X X     X   X X   X X       X             X     X   X X   X           X \n"
    "  X   X X X     X   X   X X     X X X   X   X X               X X       X X     X \n"
    "X X X             X   X         X         X     X     X   X     X X       X   X   \n"
    "X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X \n"
    "    X X   X   X   X X X               X       X       X X     X X   X X       X   \n"
    "X X     X       X       X X X X   X   X X       X   X X   X       X X   X X   X   \n"
    "  X       X   X         X     X   X         X X       X         X     X   X   X X \n"
    "X X   X X   X   X   X X       X X     X X     X X X   X X   X X   X X   X X X     \n"
    "  X       X   X   X X     X X   X X         X X X   X     X     X X   X     X X X \n"
    "  X   X X X   X X X   X   X X   X   X   X X   X X   X X X X X   X X X   X X     X \n"
    "    X     X   X X   X   X X X X       X       X       X X X         X X     X   X \n"
    "X X X   X           X X X X     X X X X X X X X   X       X X X     X   X   X   X \n"
    "          X       X   X X X X     X   X           X   X X       X                 \n"
    "  X     X X   X   X X   X X X X X X X X X X X X X X X X   X X       X   X X X     \n"
    "    X X           X X       X                       X X X X X X             X X X \n"
    "        X   X X   X X X   X X   X X X X X X X X X   X   X               X X X X   \n"
    "          X X X       X     X   X               X   X X   X       X X X           \n"
    "X X     X     X   X     X X X   X   X X X X X   X   X X       X         X   X X X \n"
    "X X X X       X     X   X X X   X   X       X   X   X       X X X   X X       X X \n"
    "X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X \n"
    "    X     X       X     X   X   X   X       X   X   X       X                     \n"
    "        X X     X X X X X   X   X   X X X X X   X   X X X     X     X   X         \n"
    "X     X   X   X   X X X X   X   X               X   X X X   X X     X     X   X   \n"
    "  X   X X X   X     X X X X X   X X X X X X X X X   X X X X X           X X X X   \n"
    "    X X   X   X     X X     X                       X X X X       X   X     X     \n"
    "    X X X X   X       X     X X X X X X X X X X X X X X       X     X   X X   X X \n"
    "            X   X X     X     X X X X X     X X X       X X X X X   X         X   \n"
    "X       X         X           X X   X X X X   X X   X X X     X X   X   X       X \n"
    "X     X       X X     X     X X     X             X X   X       X     X   X X     \n"
    "  X X X X X       X   X     X           X     X   X X X X   X X X X     X X   X X \n"
    "X             X   X X X     X X       X       X X   X   X X     X X X         X X \n"
    "    X   X X       X     X       X   X X X X X X   X X   X X X X X X X X X   X X   \n"
    "    X         X X   X       X     X   X   X       X     X X X     X       X X     \n"
    "X     X X     X X X X X X             X X X   X               X   X     X       X \n"
    "X   X X     X               X X X X X     X X     X X X X X X X X     X   X   X X \n"
    "X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X \n"
    "X           X     X X X X     X     X         X         X   X       X X   X X X   \n"
    "X   X   X X   X X X   X         X X     X X X X     X X   X   X     X   X       X \n"
    "      X     X     X     X X     X   X X   X X   X         X X       X       X   X \n"
    "X       X           X   X   X     X X   X               X     X     X X X         \n"];
}

// synthetic tests (encode-decode round-trip)

- (void)testEncodeDecode1 {
  [self testEncodeDecode:@"Abc123!" compact:YES layers:1];
}

- (void)testEncodeDecode2 {
  [self testEncodeDecode:@"Lorem ipsum. http://test/" compact:YES layers:2];
}

- (void)testEncodeDecode3 {
  [self testEncodeDecode:@"AAAANAAAANAAAANAAAANAAAANAAAANAAAANAAAANAAAANAAAAN" compact:YES layers:3];
}

- (void)testEncodeDecode4 {
  [self testEncodeDecode:@"http://test/~!@#*^%&)__ ;:'\"[]{}\\|-+-=`1029384" compact:YES layers:4];
}

- (void)testEncodeDecode5 {
  [self testEncodeDecode:@"http://test/~!@#*^%&)__ ;:'\"[]{}\\|-+-=`1029384756<>/?abc" compact:NO layers:5];
}

- (void)testEncodeDecode10 {
  [self testEncodeDecode:
   @"In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam"
    " cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum"
    " est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue"
    " auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla"
    " ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id"
    " elementum sapien dolor et diam."
                 compact:NO layers:10];
}

- (void)testEncodeDecode23 {
  [self testEncodeDecode:
   @"In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam"
   " cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum"
   " est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue"
   " auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla"
   " ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id"
   " elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend."
   " Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus"
   " justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu"
   " tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus"
   " quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec"
   " laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida,"
   " justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec"
   " lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar"
   " nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat"
   " eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra"
   " fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo"
   " diam, lobortis eu tristique ac, p. In ut magna vel mauris malesuada dictum. Nulla"
   " ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum"
   " sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet."
   " Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit"
   " felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo"
   " erat pulvinar nisi, id elementum sapien dolor et diam."
                 compact:NO layers:23];
}

- (void)testEncodeDecode31 {
  [self testEncodeDecode:
   @"In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam"
   " cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum"
   " est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue"
   " auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla"
   " ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id"
   " elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend."
   " Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus"
   " justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu"
   " tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus"
   " quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec"
   " laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida,"
   " justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec"
   " lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar"
   " nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat"
   " eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra"
   " fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo"
   " diam, lobortis eu tristique ac, p. In ut magna vel mauris malesuada dictum. Nulla"
   " ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum"
   " sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet."
   " Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit"
   " felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo"
   " erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit"
   " placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at"
   " pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est."
   " Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada"
   " dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id"
   " justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum"
   " sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat,"
   " eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet"
   " laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac"
   " nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula,"
   " massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus"
   " sed est. Ut justo diam, lobortis eu tris. In ut magna vel mauris malesuada dictum."
   " Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum"
   " sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet."
   " Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget"
   " hendrerit felis turpis nec lorem."
                 compact:NO layers:31];
}

- (void)testGenerateModeMessage {
  [self testModeMessageCompact:YES layers:2 words:29 expected:@".X .XXX.. ...X XX.. ..X .XX. .XX.X"];
  [self testModeMessageCompact:YES layers:4 words:64 expected:@"XX XXXXXX .X.. ...X ..XX .X.. XX.."];
  [self testModeMessageCompact:NO layers:21 words:660 expected:@"X.X.. .X.X..X..XX .XXX ..X.. .XXX. .X... ..XXX"];
  [self testModeMessageCompact:NO layers:32 words:4096 expected:@"XXXXX XXXXXXXXXXX X.X. ..... XXX.X ..X.. X.XXX"];
}

- (void)testStuffBits {
  [self testStuffBits:5 bits:@".X.X. X.X.X .X.X." expected:@".X.X. X.X.X .X.X."];
  [self testStuffBits:5 bits:@".X.X. ..... .X.X"
             expected:@".X.X. ....X ..X.X"];
  [self testStuffBits:3 bits:@"XX. ... ... ..X XXX .X. .."
             expected:@"XX. ..X ..X ..X ..X .XX XX. .X. ..X"];
  [self testStuffBits:6 bits:@".X.X.. ...... ..X.XX"
             expected:@".X.X.. .....X. ..X.XX XXXX."];
  [self testStuffBits:6 bits:@".X.X.. ...... ...... ..X.X."
             expected:@".X.X.. .....X .....X ....X. X.XXXX"];
  [self testStuffBits:6 bits:@".X.X.. XXXXXX ...... ..X.XX"
             expected:@".X.X.. XXXXX. X..... ...X.X XXXXX."];
  [self testStuffBits:6
                 bits:@"...... ..XXXX X..XX. .X.... .X.X.X .....X .X.... ...X.X .....X ....XX ..X... ....X. X..XXX X.XX.X"
             expected:@".....X ...XXX XX..XX ..X... ..X.X. X..... X.X... ....X. X..... X....X X..X.. .....X X.X..X XXX.XX .XXXXX"];
}

- (void)testHighLevelEncode {
  [self testHighLevelEncodeString:@"A. b."
                     expectedBits:@"...X. ..... ...XX XXX.. ...XX XXXX. XX.X"];
  [self testHighLevelEncodeString:@"Lorem ipsum."
                     expectedBits:@".XX.X XXX.. X.... X..XX ..XX. .XXX. ....X .X.X. X...X X.X.. X.XX. .XXX. XXXX. XX.X"];
  [self testHighLevelEncodeString:@"Lo. Test 123."
                     expectedBits:@".XX.X XXX.. X.... ..... ...XX XXX.. X.X.X ..XX. X.X.. X.X.X ....X XXXX. ..XX .X.. .X.X XX.X"];
  [self testHighLevelEncodeString:@"Lo...x"
                     expectedBits:@".XX.X XXX.. X.... XXXX. XX.X XX.X XX.X XXX. XXX.. XX..X"];
  [self testHighLevelEncodeString:@". x://abc/."
                     expectedBits:@"..... ...XX XXX.. XX..X ..... X.X.X ..... X.X.. ..... X.X.. ...X. ...XX ..X.. ..... X.X.. XXXX. XX.X"];
}

- (void)testHighLevelEncodeBinary {
  // binary short form single byte
  [self testHighLevelEncodeString:@"N\0N"
                     expectedBits:@".XXXX XXXXX ...X. ........ .X..XXX."];
  // binary short form consecutive bytes
  [self testHighLevelEncodeString:[NSString stringWithFormat:@"N\0%C A", 0x0080]
                     expectedBits:@".XXXX XXXXX ...X. ........ X....... ....X ...X."];
  // binary skipping over single character
  [self testHighLevelEncodeString:[NSString stringWithFormat:@"\0a%C%C A", 0x00FF, 0x0080]
                     expectedBits:@"XXXXX ..X.. ........ .XX....X XXXXXXXX X....... ....X ...X."];
  // binary long form optimization into 2 short forms (saves 1 bit)
  [self testHighLevelEncodeString:[NSString stringWithFormat:@"\0\0\0\0 \0\0\0\0 \0\0\0\0 \0\0\0\0 \0\0\0\0 \0\0\0\0 %C%C%C\0 \0\0\0\0 \0\0\0\0 ", 0x0082, 0x0084, 0x0088]
                            expectedBits:
   @"XXXXX XXXXX ........ ........ ........ ........ ..X....."
    " ........ ........ ........ ........ ..X....."
    " ........ ........ ........ ........ ..X....."
    " ........ ........ ........ ........ ..X....."
    " ........ ........ ........ ........ ..X....."
    " ........ ........ ........ ........ ..X....."
    " X.....X. XXXXX .XXX. X....X.. X...X... ........ ..X....."
    " ........ ........ ........ ........ ..X....."
    " ........ ........ ........ ........ ..X....."];
  // binary long form
  [self testHighLevelEncodeString:[NSString stringWithFormat:@"\0\0\0\0 \0\0\1\0 \0\0\2\0 \0\0\3\0 \0\0\4\0 \0\0\5\0 \0\0\6\0 \0\0\7\0 \0\0%C\0 \0\0%C\0 \0\0\u00F0\0 \0\0\u00F1\0 \0\0\u00F2\0A", 0x0008, 0x0009]
                     expectedBits:
   @"XXXXX ..... .....X...X. ........ ........ ........ ........ ..X....."
    " ........ ........ .......X ........ ..X....."
    " ........ ........ ......X. ........ ..X....."
    " ........ ........ ......XX ........ ..X....."
    " ........ ........ .....X.. ........ ..X....."
    " ........ ........ .....X.X ........ ..X....."
    " ........ ........ .....XX. ........ ..X....."
    " ........ ........ .....XXX ........ ..X....."
    " ........ ........ ....X... ........ ..X....."
    " ........ ........ ....X..X ........ ..X....."
    " ........ ........ XXXX.... ........ ..X....."
    " ........ ........ XXXX...X ........ ..X....."
    " ........ ........ XXXX..X. ........ .X.....X"];
}

// Helper routines

- (void)testEncode:(NSString *)data compact:(BOOL)compact layers:(int)layers expected:(NSString *)expected {
  unsigned char bytes[4096];
  [data getCString:(char *)bytes maxLength:4096 encoding:NSISOLatin1StringEncoding];
  int bytesLen = [data lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding];

  ZXAztecCode *aztec = [ZXAztecEncoder encode:bytes len:bytesLen minECCPercent:33];
  STAssertEquals(aztec.compact, compact, @"Unexpected symbol format (compact)");
  STAssertEquals(aztec.layers, layers, @"Unexpected nr. of layers");
  ZXBitMatrix *matrix = aztec.matrix;
  STAssertEqualObjects([matrix description], expected, @"encode() failed");
}

- (void)testEncodeDecode:(NSString *)data compact:(BOOL)compact layers:(int)layers {
  unsigned char bytes[4096];
  [data getCString:(char *)bytes maxLength:4096 encoding:NSISOLatin1StringEncoding];
  int bytesLen = [data lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding];

  ZXAztecCode *aztec = [ZXAztecEncoder encode:bytes len:bytesLen minECCPercent:25];
  STAssertEquals(aztec.compact, compact, @"Unexpected symbol format (compact)");
  STAssertEquals(aztec.layers, layers, @"Unexpected nr. of layers");
  ZXBitMatrix *matrix = aztec.matrix;
  ZXAztecDetectorResult *r = [[ZXAztecDetectorResult alloc] initWithBits:matrix points:[NSArray array] compact:aztec.compact nbDatablocks:aztec.codeWords nbLayers:aztec.layers];
  ZXDecoderResult *res = [[[ZXAztecDecoder alloc] init] decode:r error:nil];
  STAssertEqualObjects(res.text, data, @"Data did not match");
  // Check error correction by introducing a few minor errors
  srand(3735928559);
  [matrix flipX:rand() % matrix.width y:rand() % 2];
  [matrix flipX:rand() % matrix.width y:matrix.height - 2 + rand() % 2];
  [matrix flipX:rand() % 2 y:rand() % matrix.height];
  [matrix flipX:matrix.width - 2 + rand() % 2 y:rand() % matrix.height];
  r = [[ZXAztecDetectorResult alloc] initWithBits:matrix points:[NSArray array] compact:aztec.compact nbDatablocks:aztec.codeWords nbLayers:aztec.layers];
  res = [[[ZXAztecDecoder alloc] init] decode:r error:nil];
  STAssertEqualObjects(res.text, data, @"Data did not match");
}

- (void)testModeMessageCompact:(BOOL)compact layers:(int)layers words:(int)words expected:(NSString *)expected {
  ZXBitArray *inArray = [ZXAztecEncoder generateModeMessageCompact:compact layers:layers messageSizeInWords:words];
  STAssertEqualObjects([[inArray description] stringByReplacingOccurrencesOfString:@" " withString:@""], [expected stringByReplacingOccurrencesOfString:@" " withString:@""], @"generateModeMessage() failed");
}

- (void)testStuffBits:(int)wordSize bits:(NSString *)bits expected:(NSString *)expected {
  ZXBitArray *inArray = [self toBitArray:bits];
  ZXBitArray *stuffed = [ZXAztecEncoder stuffBits:inArray wordSize:wordSize];
  STAssertEqualObjects([[stuffed description] stringByReplacingOccurrencesOfString:@" " withString:@""], [expected stringByReplacingOccurrencesOfString:@" " withString:@""], @"stuffBits() failed for input string: %@", bits);
}

- (ZXBitArray *)toBitArray:(NSString *)bits {
  static NSRegularExpression *DOTX = nil;
  if (!DOTX) {
    DOTX = [NSRegularExpression regularExpressionWithPattern:@"[^.X]" options:0 error:nil];
  }

  ZXBitArray *inArray = [[ZXBitArray alloc] init];
  NSString *str = [DOTX stringByReplacingMatchesInString:bits options:0 range:NSMakeRange(0, bits.length) withTemplate:@""];
  for (int i = 0; i < str.length; i++) {
    unichar aStr = [str characterAtIndex:i];
    [inArray appendBit:aStr == 'X'];
  }
  return inArray;
}

- (void)testHighLevelEncodeString:(NSString *)s expectedBits:(NSString *)expectedBits {
  unsigned char bytes[4096];
  [s getCString:(char *)bytes maxLength:4096 encoding:NSISOLatin1StringEncoding];
  int bytesLen = [s lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding];

  ZXBitArray *bits = [ZXAztecEncoder highLevelEncode:bytes len:bytesLen];
  NSString *receivedBits = [[bits description] stringByReplacingOccurrencesOfString:@" " withString:@""];
  STAssertEqualObjects(receivedBits, [expectedBits stringByReplacingOccurrencesOfString:@" " withString:@""], @"highLevelEncode() failed for input string: %@", s);
}

@end

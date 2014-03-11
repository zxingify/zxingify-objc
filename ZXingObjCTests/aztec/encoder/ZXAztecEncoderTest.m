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

#import "ZXAztecEncoderTest.h"

unsigned int ZXAztecEncoderTest_RANDOM_SEED = 3735928559;

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

- (void)testAztecWriter {
  NSString *sampleData = [NSString stringWithFormat:@"%c 1 sample data.", 0x20AC];
  [self testWriter:sampleData encoding:NSISOLatin1StringEncoding eccPercent:25 compact:YES layers:2];
  [self testWriter:@"\u20AC 1 sample data." encoding:(NSStringEncoding) 0x8000020F eccPercent:25 compact:YES layers:2];
  [self testWriter:sampleData encoding:NSUTF8StringEncoding eccPercent:25 compact:YES layers:2];
  [self testWriter:sampleData encoding:NSUTF8StringEncoding eccPercent:100 compact:YES layers:3];
  [self testWriter:sampleData encoding:NSUTF8StringEncoding eccPercent:300 compact:YES layers:4];
  [self testWriter:sampleData encoding:NSUTF8StringEncoding eccPercent:500 compact:NO layers:5];
  // Test AztecWriter defaults
  NSString *data = @"In ut magna vel mauris malesuada";
  ZXAztecWriter *writer = [[ZXAztecWriter alloc] init];
  ZXBitMatrix *matrix = [writer encode:data format:kBarcodeFormatAztec width:0 height:0 error:nil];
  int8_t bytes[4096];
  [data getCString:(char *)bytes maxLength:4096 encoding:NSISOLatin1StringEncoding];
  int bytesLen = (int)[data lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding];
  ZXAztecCode *aztec = [ZXAztecEncoder encode:bytes len:bytesLen minECCPercent:ZX_DEFAULT_AZTEC_EC_PERCENT];
  ZXBitMatrix *expectedMatrix = aztec.matrix;
  XCTAssertEqualObjects(expectedMatrix, matrix, @"Expected matrices to be equal");
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
  int8_t bytes[4096];
  [data getCString:(char *)bytes maxLength:4096 encoding:NSISOLatin1StringEncoding];
  int bytesLen = (int)[data lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding];

  ZXAztecCode *aztec = [ZXAztecEncoder encode:bytes len:bytesLen minECCPercent:33];
  XCTAssertEqual(aztec.compact, compact, @"Unexpected symbol format (compact)");
  XCTAssertEqual(aztec.layers, layers, @"Unexpected nr. of layers");
  ZXBitMatrix *matrix = aztec.matrix;
  XCTAssertEqualObjects([matrix description], expected, @"encode() failed");
}

- (void)testEncodeDecode:(NSString *)data compact:(BOOL)compact layers:(int)layers {
  int8_t bytes[4096];
  [data getCString:(char *)bytes maxLength:4096 encoding:NSISOLatin1StringEncoding];
  int bytesLen = (int)[data lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding];

  ZXAztecCode *aztec = [ZXAztecEncoder encode:bytes len:bytesLen minECCPercent:25];
  XCTAssertEqual(aztec.compact, compact, @"Unexpected symbol format (compact)");
  XCTAssertEqual(aztec.layers, layers, @"Unexpected nr. of layers");
  ZXBitMatrix *matrix = aztec.matrix;
  ZXAztecDetectorResult *r = [[ZXAztecDetectorResult alloc] initWithBits:matrix points:@[] compact:aztec.compact nbDatablocks:aztec.codeWords nbLayers:aztec.layers];
  ZXDecoderResult *res = [[[ZXAztecDecoder alloc] init] decode:r error:nil];
  XCTAssertEqualObjects(res.text, data, @"Data did not match");
  // Check error correction by introducing a few minor errors
  srand(ZXAztecEncoderTest_RANDOM_SEED);
  [matrix flipX:rand() % matrix.width y:rand() % 2];
  [matrix flipX:rand() % matrix.width y:matrix.height - 2 + rand() % 2];
  [matrix flipX:rand() % 2 y:rand() % matrix.height];
  [matrix flipX:matrix.width - 2 + rand() % 2 y:rand() % matrix.height];
  r = [[ZXAztecDetectorResult alloc] initWithBits:matrix points:@[] compact:aztec.compact nbDatablocks:aztec.codeWords nbLayers:aztec.layers];
  res = [[[ZXAztecDecoder alloc] init] decode:r error:nil];
  XCTAssertEqualObjects(res.text, data, @"Data did not match");
}

- (void)testWriter:(NSString *)data encoding:(NSStringEncoding)encoding eccPercent:(int)eccPercent compact:(BOOL)compact layers:(int)layers {
  // 1. Perform an encode-decode round-trip because it can be lossy.
  // 2. Aztec Decoder currently always decodes the data with a LATIN-1 charset:
  NSData *rawData = [data dataUsingEncoding:encoding];
  int8_t *bytes = (int8_t *)[rawData bytes];
  int bytesLen = (int)[rawData length];
  NSString *expectedData = [[NSString alloc] initWithBytes:bytes length:bytesLen encoding:NSISOLatin1StringEncoding];
  ZXEncodeHints *hints = [ZXEncodeHints hints];
  hints.encoding = encoding;
  hints.errorCorrectionPercent = @(eccPercent);
  ZXAztecWriter *writer = [[ZXAztecWriter alloc] init];
  ZXBitMatrix *matrix = [writer encode:data format:kBarcodeFormatAztec width:0 height:0 hints:hints error:nil];
  ZXAztecCode *aztec = [ZXAztecEncoder encode:bytes len:bytesLen minECCPercent:eccPercent];
  XCTAssertEqual(aztec.compact, compact, @"Unexpected symbol format (compact)");
  XCTAssertEqual(aztec.layers, layers, @"Unexpected nr. of layers");
  ZXBitMatrix *matrix2 = aztec.matrix;
  XCTAssertEqualObjects(matrix2, matrix, @"Expected matrices to be equal");
  ZXAztecDetectorResult *r = [[ZXAztecDetectorResult alloc] initWithBits:matrix points:@[] compact:aztec.compact nbDatablocks:aztec.codeWords nbLayers:aztec.layers];
  ZXDecoderResult *res = [[[ZXAztecDecoder alloc] init] decode:r error:nil];
  XCTAssertEqualObjects(res.text, expectedData, @"Data did not match");
  // Check error correction by introducing up to eccPercent errors
  srand(ZXAztecEncoderTest_RANDOM_SEED);
  NSInteger ecWords = aztec.codeWords * eccPercent / 100;
  for (NSInteger i = 0; i < ecWords; i++) {
    // don't touch the core
    int x = rand() % 2 > 0 ?
      rand() % aztec.layers * 2
      : matrix.width - 1 - (rand() % aztec.layers * 2);
    int y = rand() % 2 > 0 ?
      rand() % aztec.layers * 2
      : matrix.height - 1 - (rand() % aztec.layers * 2);
    [matrix flipX:x y:y];
  }
  r = [[ZXAztecDetectorResult alloc] initWithBits:matrix points:@[] compact:aztec.compact nbDatablocks:aztec.codeWords nbLayers:aztec.layers];
  res = [[[ZXAztecDecoder alloc] init] decode:r error:nil];
  XCTAssertEqualObjects(res.text, expectedData, @"Data did not match");
}

- (void)testModeMessageCompact:(BOOL)compact layers:(int)layers words:(int)words expected:(NSString *)expected {
  ZXBitArray *inArray = [ZXAztecEncoder generateModeMessageCompact:compact layers:layers messageSizeInWords:words];
  XCTAssertEqualObjects([[inArray description] stringByReplacingOccurrencesOfString:@" " withString:@""], [expected stringByReplacingOccurrencesOfString:@" " withString:@""], @"generateModeMessage() failed");
}

- (void)testStuffBits:(int)wordSize bits:(NSString *)bits expected:(NSString *)expected {
  ZXBitArray *inArray = [self toBitArray:bits];
  ZXBitArray *stuffed = [ZXAztecEncoder stuffBits:inArray wordSize:wordSize];
  XCTAssertEqualObjects([[stuffed description] stringByReplacingOccurrencesOfString:@" " withString:@""], [expected stringByReplacingOccurrencesOfString:@" " withString:@""], @"stuffBits() failed for input string: %@", bits);
}

- (ZXBitArray *)toBitArray:(NSString *)bits {
  static NSRegularExpression *DOTX = nil;
  if (!DOTX) {
    DOTX = [NSRegularExpression regularExpressionWithPattern:@"[^.X]" options:0 error:nil];
  }

  ZXBitArray *inArray = [[ZXBitArray alloc] init];
  NSString *str = [DOTX stringByReplacingMatchesInString:bits options:0 range:NSMakeRange(0, bits.length) withTemplate:@""];
  for (NSInteger i = 0; i < str.length; i++) {
    unichar aStr = [str characterAtIndex:i];
    [inArray appendBit:aStr == 'X'];
  }
  return inArray;
}

- (void)testHighLevelEncodeString:(NSString *)s expectedBits:(NSString *)expectedBits {
  int8_t bytes[4096];
  [s getCString:(char *)bytes maxLength:4096 encoding:NSISOLatin1StringEncoding];
  int bytesLen = (int)[s lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding];

  ZXBitArray *bits = [ZXAztecEncoder highLevelEncode:bytes len:bytesLen];
  NSString *receivedBits = [[bits description] stringByReplacingOccurrencesOfString:@" " withString:@""];
  XCTAssertEqualObjects(receivedBits, [expectedBits stringByReplacingOccurrencesOfString:@" " withString:@""], @"highLevelEncode() failed for input string: %@", s);
}

@end

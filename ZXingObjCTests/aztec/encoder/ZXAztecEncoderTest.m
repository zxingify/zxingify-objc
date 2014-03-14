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
    "  X       X   X     X X   X   X X   X X   X X X X X X   X X           X   X   X X \n"
    "X X   X X   X   X X X X   X X X X X X X X   X   X       X X   X X X X   X X X     \n"
    "  X       X   X     X       X X     X X   X   X   X     X X   X X X   X     X X X \n"
    "  X   X X X   X X       X X X         X X           X   X   X   X X X   X X     X \n"
    "    X     X   X X     X X X X     X   X     X X X X   X X   X X   X X X     X   X \n"
    "X X X   X             X         X X X X X   X   X X   X   X   X X   X   X   X   X \n"
    "          X       X X X   X X     X   X           X   X X X X   X X               \n"
    "  X     X X   X   X       X X X X X X X X X X X X X X X   X   X X   X   X X X     \n"
    "    X X                 X   X                       X X   X       X         X X X \n"
    "        X   X X   X X X X X X   X X X X X X X X X   X     X X           X X X X   \n"
    "          X X X   X     X   X   X               X   X X     X X X   X X           \n"
    "X X     X     X   X   X   X X   X   X X X X X   X   X X X X X X X       X   X X X \n"
    "X X X X       X       X   X X   X   X       X   X   X     X X X     X X       X X \n"
    "X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X \n"
    "    X     X       X         X   X   X       X   X   X     X   X X                 \n"
    "        X X     X X X X X   X   X   X X X X X   X   X X X     X X X X   X         \n"
    "X     X   X   X         X   X   X               X   X X   X X   X X X     X   X   \n"
    "  X   X X X   X   X X   X X X   X X X X X X X X X   X X         X X     X X X X   \n"
    "    X X   X   X   X X X     X                       X X X   X X   X   X     X     \n"
    "    X X X X   X         X   X X X X X X X X X X X X X X   X       X X   X X   X X \n"
    "            X   X   X X       X X X X X     X X X       X       X X X         X   \n"
    "X       X         X   X X X X   X     X X     X X     X X           X   X       X \n"
    "X     X       X X X X X     X   X X X X   X X X     X       X X X X   X   X X   X \n"
    "  X X X X X               X     X X X   X       X X   X X   X X X X     X X       \n"
    "X             X         X   X X   X X     X     X     X   X   X X X X             \n"
    "    X   X X       X     X       X   X X X X X X   X X   X X X X X X X X X   X   X \n"
    "    X         X X   X       X     X   X   X       X     X X X     X       X X X X \n"
    "X     X X     X X X X X X             X X X   X               X   X     X     X X \n"
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
  [self testEncodeDecode:@"http://test/~!@#*^%&)__ ;:'\"[]{}\\|-+-=`1029384756<>/?abc"
                   "Four score and seven our forefathers brought forth" compact:NO layers:5];
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
                                   // 'A'  P/S   '. ' L/L    b    D/L    '.'
                     expectedBits:@"...X. ..... ...XX XXX.. ...XX XXXX. XX.X"];
  [self testHighLevelEncodeString:@"Lorem ipsum."
                                   // 'L'  L/L   'o'   'r'   'e'   'm'   ' '   'i'   'p'   's'   'u'   'm'   D/L   '.'
                     expectedBits:@".XX.X XXX.. X.... X..XX ..XX. .XXX. ....X .X.X. X...X X.X.. X.XX. .XXX. XXXX. XX.X"];
  [self testHighLevelEncodeString:@"Lo. Test 123."
                                   // 'L'  L/L   'o'   P/S   '. '  U/S   'T'   'e'   's'   't'    D/L   ' '  '1'  '2'  '3'  '.'
                     expectedBits:@".XX.X XXX.. X.... ..... ...XX XXX.. X.X.X ..XX. X.X.. X.X.X  XXXX. ...X ..XX .X.. .X.X XX.X"];
  [self testHighLevelEncodeString:@"Lo...x"
                                   // 'L'  L/L   'o'   D/L   '.'  '.'  '.'  U/L  L/L   'x'
                     expectedBits:@".XX.X XXX.. X.... XXXX. XX.X XX.X XX.X XXX. XXX.. XX..X"];
  [self testHighLevelEncodeString:@". x://abc/."
                                  //P/S   '. '  L/L   'x'   P/S   ':'   P/S   '/'   P/S   '/'   'a'   'b'   'c'   P/S   '/'   D/L   '.'
                     expectedBits:@"..... ...XX XXX.. XX..X ..... X.X.X ..... X.X.. ..... X.X.. ...X. ...XX ..X.. ..... X.X.. XXXX. XX.X"];
  // Uses Binary/Shift rather than Lower/Shift to save two bits.
  [self testHighLevelEncodeString:@"ABCdEFG"
                                   //'A'   'B'   'C'   B/S    =1    'd'     'E'   'F'   'G'
                     expectedBits:@"...X. ...XX ..X.. XXXXX ....X .XX..X.. ..XX. ..XXX .X..."];

  [self testHighLevelEncodeString:
   // Found on an airline boarding pass.  Several stretches of Binary shift are
   // necessary to keep the bitcount so low.
   @"09  UAG    ^160MEUCIQC0sYS/HpKxnBELR1uB85R20OoqqwFGa0q2uEi"
   "Ygh6utAIgLl1aBVM4EOTQtMQQYH9M2Z3Dp4qnA/fwWuQ+M8L3V8U="
                  receivedBits:823];
}

- (void)testHighLevelEncodeBinary {
  // binary short form single byte
  [self testHighLevelEncodeString:@"N\0N"
                                   // 'N'  B/S    =1   '\0'      N
                     expectedBits:@".XXXX XXXXX ....X ........ .XXXX"];   // Encode "N" in UPPER

  [self testHighLevelEncodeString:@"N\0n"
                                   // 'N'  B/S    =2   '\0'       'n'
                     expectedBits:@".XXXX XXXXX ...X. ........ .XX.XXX."];   // Encode "n" in BINARY

  // binary short form consecutive bytes
  [self testHighLevelEncodeString:[NSString stringWithFormat:@"N\0%C A", 0x0080]
                                   // 'N'  B/S    =2    '\0'    \u0080   ' '  'A'
                     expectedBits:@".XXXX XXXXX ...X. ........ X....... ....X ...X."];

  // binary skipping over single character
  [self testHighLevelEncodeString:[NSString stringWithFormat:@"\0a%C%C A", 0x00FF, 0x0080]
                                   // B/S  =4    '\0'      'a'     '\3ff'   '\200'   ' '   'A'
                     expectedBits:@"XXXXX ..X.. ........ .XX....X XXXXXXXX X....... ....X ...X."];

  // getting into binary mode from digit mode
  [self testHighLevelEncodeString:@"1234\0"
                                   //D/L   '1'  '2'  '3'  '4'  U/L  B/S    =1    \0
                     expectedBits:@"XXXX. ..XX .X.. .X.X .XX. XXX. XXXXX ....X ........"];

  // Create a string in which every character requires binary
  NSMutableString *sb = [NSMutableString string];
  for (int i = 0; i <= 3000; i++) {
    [sb appendFormat:@"%c", (char)(128 + (i % 30))];
  }
  // Test the output generated by Binary/Switch, particularly near the
  // places where the encoding changes: 31, 62, and 2047+31=2078
  for (NSNumber *n in @[ @1, @2, @3, @10, @29, @30, @31, @32, @33,
                         @60, @61, @62, @63, @64, @2076, @2077, @2078, @2079, @2080, @3000 ]) {
    int i = [n intValue];
    // This is the expected length of a binary string of length "i"
    int expectedLength = (8 * i) +
      ( (i <= 31) ? 10 : (i <= 62) ? 20 : (i <= 2078) ? 21 : 31);
    // Verify that we are correct about the length.
    [self testHighLevelEncodeString:[sb substringToIndex:i] receivedBits:expectedLength];
    // A lower case letter at the beginning will be merged into binary mode
    [self testHighLevelEncodeString:[@"a" stringByAppendingString:[sb substringToIndex:i - 1]] receivedBits:expectedLength];
    // A lower case letter at the end will also be merged into binary mode
    [self testHighLevelEncodeString:[[sb substringToIndex:i - 1] stringByAppendingString:@"a"] receivedBits:expectedLength];
    // A lower case letter at both ends will enough to latch us into LOWER.
    [self testHighLevelEncodeString:[NSString stringWithFormat:@"a%@b", [sb substringToIndex:i]]
                       receivedBits:expectedLength + 15];
  }
}

- (void)testHighLevelEncodePairs {
  // Typical usage
  [self testHighLevelEncodeString:@"ABC. DEF\r\n"
                                   //  A     B    C    P/S   .<sp>   D    E     F    P/S   \r\n
                     expectedBits:@"...X. ...XX ..X.. ..... ...XX ..X.X ..XX. ..XXX ..... ...X."];

  // We should latch to PUNCT mode, rather than shift.  Also check all pairs
  [self testHighLevelEncodeString:@"A. : , \r\n"
                                   // 'A'    M/L   P/L   ". "  ": "   ", " "\r\n"
                     expectedBits:@"...X. XXX.X XXXX. ...XX ..X.X  ..X.. ...X."];

  // Latch to DIGIT rather than shift to PUNCT
  [self testHighLevelEncodeString:@"A. 1234"
                                   // 'A'  D/L   '.'  ' '  '1' '2'   '3'  '4'
                     expectedBits:@"...X. XXXX. XX.X ...X ..XX .X.. .X.X .X X."];

  // Don't bother leaving Binary Shift.
  [self testHighLevelEncodeString:[NSString stringWithFormat:@"A%c. %c", '\200', '\200']
                                   // 'A'  B/S    =2    \200      "."     " "     \200
                     expectedBits:@"...X. XXXXX ..X.. X....... ..X.XXX. ..X..... X......."];
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

- (NSString *)highLevelDecode:(ZXBitArray *)bitArray {
  int resultSize = bitArray.size;
  BOOL result[resultSize];
  for (int i = 0; i < resultSize; i++) {
    result[i] = [bitArray get:i];
  }
  return [ZXAztecDecoder highLevelDecode:result length:resultSize error:nil];
}

- (void)testHighLevelEncodeString:(NSString *)s expectedBits:(NSString *)expectedBits {
  int8_t bytes[4096];
  [s getCString:(char *)bytes maxLength:4096 encoding:NSISOLatin1StringEncoding];
  int bytesLen = (int)[s lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding];

  ZXBitArray *bits = [[[ZXAztecHighLevelEncoder alloc] initWithData:bytes textLength:bytesLen] encode];
  NSString *receivedBits = [[bits description] stringByReplacingOccurrencesOfString:@" " withString:@""];
  XCTAssertEqualObjects(receivedBits, [expectedBits stringByReplacingOccurrencesOfString:@" " withString:@""], @"highLevelEncode() failed for input string: %@", s);
  XCTAssertEqualObjects(s, [self highLevelDecode:bits]);
}

- (void)testHighLevelEncodeString:(NSString *)s receivedBits:(int)receivedBits {
  int8_t bytes[4096];
  [s getCString:(char *)bytes maxLength:4096 encoding:NSISOLatin1StringEncoding];
  int bytesLen = (int)[s lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding];

  ZXBitArray *bits = [[[ZXAztecHighLevelEncoder alloc] initWithData:bytes textLength:bytesLen] encode];
  NSUInteger receivedBitCount = [[[bits description] stringByReplacingOccurrencesOfString:@" " withString:@""] length];
  XCTAssertEqual(receivedBitCount, receivedBitCount, @"highLevelEncode() failed for input string: %@", s);
  XCTAssertEqualObjects(s, [self highLevelDecode:bits]);
}

@end

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

#import "ZXDataMatrixHighLevelEncodeTestCase.h"

static NSArray *TEST_SYMBOLS;

@implementation ZXDataMatrixHighLevelEncodeTestCase

+ (void)initialize {
  if ([self class] != [ZXDataMatrixHighLevelEncodeTestCase class]) return;

  TEST_SYMBOLS = @[[[ZXDataMatrixSymbolInfo alloc] initWithRectangular:NO dataCapacity:3 errorCodewords:5 matrixWidth:8 matrixHeight:8 dataRegions:1],
                   [[ZXDataMatrixSymbolInfo alloc] initWithRectangular:NO dataCapacity:5 errorCodewords:7 matrixWidth:10 matrixHeight:10 dataRegions:1],
                   /*rect*/[[ZXDataMatrixSymbolInfo alloc] initWithRectangular:YES dataCapacity:5 errorCodewords:7 matrixWidth:16 matrixHeight:6 dataRegions:1],
                   [[ZXDataMatrixSymbolInfo alloc] initWithRectangular:NO dataCapacity:8 errorCodewords:10 matrixWidth:12 matrixHeight:12 dataRegions:1],
                   /*rect*/[[ZXDataMatrixSymbolInfo alloc] initWithRectangular:YES dataCapacity:10 errorCodewords:11 matrixWidth:14 matrixHeight:6 dataRegions:2],
                   [[ZXDataMatrixSymbolInfo alloc] initWithRectangular:NO dataCapacity:13 errorCodewords:0 matrixWidth:0 matrixHeight:0 dataRegions:1],
                   [[ZXDataMatrixSymbolInfo alloc] initWithRectangular:NO dataCapacity:77 errorCodewords:0 matrixWidth:0 matrixHeight:0 dataRegions:1]];
  //The last entries are fake entries to test special conditions with C40 encoding
}

- (void)useTestSymbols {
  [ZXDataMatrixSymbolInfo overrideSymbolSet:TEST_SYMBOLS];
}

- (void)resetSymbols {
  [ZXDataMatrixSymbolInfo overrideSymbolSet:[ZXDataMatrixSymbolInfo prodSymbols]];
}

- (void)testASCIIEncodation {
  NSString *visualized = [self encodeHighLevel:@"123456"];
  XCTAssertEqualObjects(@"142 164 186", visualized);

  visualized = [self encodeHighLevel:@"123456£"];
  XCTAssertEqualObjects(@"142 164 186 235 36", visualized);

  visualized = [self encodeHighLevel:@"30Q324343430794<OQQ"];
  XCTAssertEqualObjects(@"160 82 162 173 173 173 137 224 61 80 82 82", visualized);
}

- (void)testC40EncodationBasic1 {
  NSString *visualized = [self encodeHighLevel:@"AIMAIMAIM"];
  XCTAssertEqualObjects(@"230 91 11 91 11 91 11 254", visualized);
  //230 shifts to C40 encodation, 254 unlatches, "else" case
}

- (void)testC40EncodationBasic2 {
  NSString *visualized = [self encodeHighLevel:@"AIMAIAB"];
  XCTAssertEqualObjects(@"230 91 11 90 255 254 67 129", visualized);
  //"B" is normally encoded as "15" (one C40 value)
  //"else" case: "B" is encoded as ASCII

  visualized = [self encodeHighLevel:@"AIMAIAb"];
  XCTAssertEqualObjects(visualized, @"66 74 78 66 74 66 99 129", @""); //Encoded as ASCII
  //Alternative solution:
  //XCTAssertEqualObjects(@"230 91 11 90 255 254 99 129", visualized);
  //"b" is normally encoded as "Shift 3, 2" (two C40 values)
  //"else" case: "b" is encoded as ASCII

  visualized = [self encodeHighLevel:@"AIMAIMAIMË"];
  XCTAssertEqualObjects(@"230 91 11 91 11 91 11 254 235 76", visualized);
  //Alternative solution:
  //XCTAssertEqualObjects(@"230 91 11 91 11 91 11 11 9 254", visualized);
  //Expl: 230 = shift to C40, "91 11" = "AIM",
  //"11 9" = "�" = "Shift 2, UpperShift, <char>
  //"else" case

  visualized = [self encodeHighLevel:@"AIMAIMAIMë"];
  XCTAssertEqualObjects(@"230 91 11 91 11 91 11 254 235 108", visualized); //Activate when additional rectangulars are available
  //Expl: 230 = shift to C40, "91 11" = "AIM",
  //"�" in C40 encodes to: 1 30 2 11 which doesn't fit into a triplet
  //"10 243" =
  //254 = unlatch, 235 = Upper Shift, 108 = � = 0xEB/235 - 128 + 1
  //"else" case
}

- (void)testC40EncodationSpecExample {
  //Example in Figure 1 in the spec
  NSString *visualized = [self encodeHighLevel:@"A1B2C3D4E5F6G7H8I9J0K1L2"];
  XCTAssertEqualObjects(@"230 88 88 40 8 107 147 59 67 126 206 78 126 144 121 35 47 254", visualized);
}

- (void)testC40EncodationSpecialCases1 {
  //Special tests avoiding ultra-long test strings because these tests are only used
  //with the 16x48 symbol (47 data codewords)
  [self useTestSymbols];

  NSString *visualized = [self encodeHighLevel:@"AIMAIMAIMAIMAIMAIM"];
  XCTAssertEqualObjects(@"230 91 11 91 11 91 11 91 11 91 11 91 11", visualized);
  //case "a": Unlatch is not required

  visualized = [self encodeHighLevel:@"AIMAIMAIMAIMAIMAI"];
  XCTAssertEqualObjects(@"230 91 11 91 11 91 11 91 11 91 11 90 241", visualized);
  //case "b": Add trailing shift 0 and Unlatch is not required

  visualized = [self encodeHighLevel:@"AIMAIMAIMAIMAIMA"];
  XCTAssertEqualObjects(@"230 91 11 91 11 91 11 91 11 91 11 254 66", visualized);
  //case "c": Unlatch and write last character in ASCII

  [self resetSymbols];

  visualized = [self encodeHighLevel:@"AIMAIMAIMAIMAIMAI"];
  XCTAssertEqualObjects(@"230 91 11 91 11 91 11 91 11 91 11 254 66 74 129 237", visualized);

  visualized = [self encodeHighLevel:@"AIMAIMAIMA"];
  XCTAssertEqualObjects(@"230 91 11 91 11 91 11 66", visualized);
  //case "d": Skip Unlatch and write last character in ASCII
}

- (void)testC40EncodationSpecialCases2 {
  NSString *visualized = [self encodeHighLevel:@"AIMAIMAIMAIMAIMAIMAI"];
  XCTAssertEqualObjects(@"230 91 11 91 11 91 11 91 11 91 11 91 11 254 66 74", visualized);
  //available > 2, rest = 2 --> unlatch and encode as ASCII
}

- (void)testTextEncodation {
  NSString *visualized = [self encodeHighLevel:@"aimaimaim"];
  XCTAssertEqualObjects(@"239 91 11 91 11 91 11 254", visualized);
  //239 shifts to Text encodation, 254 unlatches

  visualized = [self encodeHighLevel:@"aimaimaim'"];
  XCTAssertEqualObjects(@"239 91 11 91 11 91 11 254 40 129", visualized);
  //XCTAssertEqualObjects("239 91 11 91 11 91 11 7 49 254", visualized);
  //This is an alternative, but doesn't strictly follow the rules in the spec.

  visualized = [self encodeHighLevel:@"aimaimaIm"];
  XCTAssertEqualObjects(@"239 91 11 91 11 87 218 110", visualized);

  visualized = [self encodeHighLevel:@"aimaimaimB"];
  XCTAssertEqualObjects(@"239 91 11 91 11 91 11 254 67 129", visualized);

  visualized = [self encodeHighLevel:[NSString stringWithFormat:@"aimaimaim{txt}%C", (unichar)0x0004]];
  XCTAssertEqualObjects(@"239 91 11 91 11 91 11 16 218 236 107 181 69 254 129 237", visualized);
}

- (void)testX12Encodation {
  //238 shifts to X12 encodation, 254 unlatches

  NSString *visualized = [self encodeHighLevel:@"ABC>ABC123>AB"];
  XCTAssertEqualObjects(@"238 89 233 14 192 100 207 44 31 67", visualized);

  visualized = [self encodeHighLevel:@"ABC>ABC123>ABC"];
  XCTAssertEqualObjects(@"238 89 233 14 192 100 207 44 31 254 67 68", visualized);

  visualized = [self encodeHighLevel:@"ABC>ABC123>ABCD"];
  XCTAssertEqualObjects(@"238 89 233 14 192 100 207 44 31 96 82 254", visualized);

  visualized = [self encodeHighLevel:@"ABC>ABC123>ABCDE"];
  XCTAssertEqualObjects(@"238 89 233 14 192 100 207 44 31 96 82 70", visualized);

  visualized = [self encodeHighLevel:@"ABC>ABC123>ABCDEF"];
  XCTAssertEqualObjects(@"238 89 233 14 192 100 207 44 31 96 82 254 70 71 129 237", visualized);
}

- (void)testEDIFACTEncodation {
  //240 shifts to EDIFACT encodation

  NSString *visualized = [self encodeHighLevel:@".A.C1.3.DATA.123DATA.123DATA"];
  XCTAssertEqualObjects(@"240 184 27 131 198 236 238 16 21 1 187 28 179 16 21 1 187 28 179 16 21 1", visualized);

  visualized = [self encodeHighLevel:@".A.C1.3.X.X2.."];
  XCTAssertEqualObjects(@"240 184 27 131 198 236 238 98 230 50 47 47", visualized);

  visualized = [self encodeHighLevel:@".A.C1.3.X.X2."];
  XCTAssertEqualObjects(@"240 184 27 131 198 236 238 98 230 50 47 129", visualized);

  visualized = [self encodeHighLevel:@".A.C1.3.X.X2"];
  XCTAssertEqualObjects(@"240 184 27 131 198 236 238 98 230 50", visualized);

  visualized = [self encodeHighLevel:@".A.C1.3.X.X"];
  XCTAssertEqualObjects(@"240 184 27 131 198 236 238 98 230 31", visualized);

  visualized = [self encodeHighLevel:@".A.C1.3.X."];
  XCTAssertEqualObjects(@"240 184 27 131 198 236 238 98 231 192", visualized);

  visualized = [self encodeHighLevel:@".A.C1.3.X"];
  XCTAssertEqualObjects(@"240 184 27 131 198 236 238 89", visualized);

  //Checking temporary unlatch from EDIFACT
  visualized = [self encodeHighLevel:@".XXX.XXX.XXX.XXX.XXX.XXX.üXX.XXX.XXX.XXX.XXX.XXX.XXX"];
  XCTAssertEqualObjects(@"240 185 134 24 185 134 24 185 134 24 185 134 24 185 134 24 185 134 24"
               @" 124 47 235 125 240" //<-- this is the temporary unlatch
               @" 97 139 152 97 139 152 97 139 152 97 139 152 97 139 152 97 139 152 89 89",
               visualized);
}

- (void)testBase256Encodation {
  //231 shifts to Base256 encodation

  NSString *visualized = [self encodeHighLevel:@"\u00ABäöüé\u00BB"];
  XCTAssertEqualObjects(@"231 44 108 59 226 126 1 104", visualized);
  visualized = [self encodeHighLevel:@"\u00ABäöüéà\u00BB"];
  XCTAssertEqualObjects(@"231 51 108 59 226 126 1 141 254 129", visualized);
  visualized = [self encodeHighLevel:@"\u00ABäöüéàá\u00BB"];
  XCTAssertEqualObjects(@"231 44 108 59 226 126 1 141 36 147", visualized);

  visualized = [self encodeHighLevel:@" 23£"]; //ASCII only (for reference)
  XCTAssertEqualObjects(@"33 153 235 36 129", visualized);

  visualized = [self encodeHighLevel:@"\u00ABäöüé\u00BB 234"]; //Mixed Base256 + ASCII
  XCTAssertEqualObjects(@"231 51 108 59 226 126 1 104 99 153 53 129", visualized);

  visualized = [self encodeHighLevel:@"\u00ABäöüé\u00BB 23£ 1234567890123456789"];
  XCTAssertEqualObjects(@"231 55 108 59 226 126 1 104 99 10 161 167 185 142 164 186 208"
               @" 220 142 164 186 208 58 129 59 209 104 254 150 45", visualized);

  visualized = [self encodeHighLevel:[self createBinaryMessage:20]];
  XCTAssertEqualObjects(@"231 44 108 59 226 126 1 141 36 5 37 187 80 230 123 17 166 60 210 103 253 150", visualized);
  visualized = [self encodeHighLevel:[self createBinaryMessage:19]]; //padding necessary at the end
  XCTAssertEqualObjects(@"231 63 108 59 226 126 1 141 36 5 37 187 80 230 123 17 166 60 210 103 1 129", visualized);

  visualized = [self encodeHighLevel:[self createBinaryMessage:276]];
  XCTAssertTrue([visualized hasPrefix:@"231 38 219 2 208 120 20 150 35"]);
  XCTAssertTrue([visualized hasSuffix:@"146 40 194 129"]);

  visualized = [self encodeHighLevel:[self createBinaryMessage:277]];
  XCTAssertTrue([visualized hasPrefix:@"231 38 220 2 208 120 20 150 35"]);
  XCTAssertTrue([visualized hasSuffix:@"146 40 190 87"]);
}

- (NSString *)createBinaryMessage:(int)len {
  NSMutableString *sb = [NSMutableString string];
  [sb appendString:@"\u00ABäöüéàá-"];
  for (int i = 0; i < len - 9; i++) {
    [sb appendFormat:@"%C", (unichar)0x00B7];
  }
  [sb appendString:@"\u00BB"];
  return [NSString stringWithString:sb];
}

- (void)testUnlatchingFromC40 {
  NSString *visualized = [self encodeHighLevel:@"AIMAIMAIMAIMaimaimaim"];
  XCTAssertEqualObjects(@"230 91 11 91 11 91 11 254 66 74 78 239 91 11 91 11 91 11", visualized);
}

- (void)testUnlatchingFromText {
  NSString *visualized = [self encodeHighLevel:@"aimaimaimaim12345678"];
  XCTAssertEqualObjects(@"239 91 11 91 11 91 11 91 11 254 142 164 186 208 129 237", visualized);
}

- (void)testHelloWorld {
  NSString *visualized = [self encodeHighLevel:@"Hello World!"];
  XCTAssertEqualObjects(@"73 239 116 130 175 123 148 64 158 233 254 34", visualized);
}

- (void)testBug1664266 {
  //There was an exception and the encoder did not handle the unlatching from
  //EDIFACT encoding correctly

  NSString *visualized = [self encodeHighLevel:@"CREX-TAN:h"];
  XCTAssertEqualObjects(@"240 13 33 88 181 64 78 124 59 105", visualized);

  visualized = [self encodeHighLevel:@"CREX-TAN:hh"];
  XCTAssertEqualObjects(@"240 13 33 88 181 64 78 124 59 105 105 129", visualized);

  visualized = [self encodeHighLevel:@"CREX-TAN:hhh"];
  XCTAssertEqualObjects(@"240 13 33 88 181 64 78 124 59 105 105 105", visualized);
}

- (void)testX12Unlatch {
  NSString *visualized = [self encodeHighLevel:@"*DTCP01"];
  XCTAssertEqualObjects(@"238 9 10 104 141 254 50 129", visualized);
}

- (void)testX12Unlatch2 {
  NSString *visualized = [self encodeHighLevel:@"*DTCP0"];
  XCTAssertEqualObjects(@"238 9 10 104 141", visualized);
}

- (void)testBug3048549 {
  //There was an IllegalArgumentException for an illegal character here because
  //of an encoding problem of the character 0x0060 in Java source code.

  NSString *visualized = [self encodeHighLevel:@"fiykmj*Rh2`,e6"];
  XCTAssertEqualObjects(@"239 122 87 154 40 7 171 115 207 12 130 71 155 254 129 237", visualized);
}

- (void)testMacroCharacters {
  NSString *visualized = [self encodeHighLevel:[NSString stringWithFormat:@"[)>%C05%C5555%C6666%C%C",
                                                (unichar)0x001E, (unichar)0x001D, (unichar)0x001C,
                                                (unichar)0x001E, (unichar)0x0004]];
  //XCTAssertEqualObjects(@"92 42 63 31 135 30 185 185 29 196 196 31 5 129 87 237", visualized);
  XCTAssertEqualObjects(@"236 185 185 29 196 196 129 56", visualized);
}

- (NSString *)encodeHighLevel:(NSString *)msg {
  NSString *encoded = [ZXDataMatrixHighLevelEncoder encodeHighLevel:msg];
  //[ZXDecodeHighLevel decode:encoded];
  return [[self class] visualize:encoded];
}

- (void)testEncodingWithStartAsX12AndLatchToEDIFACTInTheMiddle {
  NSString *visualized = [self encodeHighLevel:@"*MEMANT-1F-MESTECH"];
  XCTAssertEqualObjects(@"238 10 99 164 204 254 240 82 220 70 180 209 83 80 80 200", visualized);
}

+ (NSString *)visualize:(NSString *)codewords {
  NSMutableString *sb = [NSMutableString string];
  for (int i = 0; i < codewords.length; i++) {
    if (i > 0) {
      [sb appendString:@" "];
    }
    [sb appendFormat:@"%d", [codewords characterAtIndex:i] & 0xFF];
  }
  return [NSString stringWithString:sb];
}

@end

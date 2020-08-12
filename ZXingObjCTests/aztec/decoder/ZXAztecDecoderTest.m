/*
 * Copyright 2015 ZXing authors
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

#import "ZXByteArray.h"
#import "ZXBitMatrix.h"
#import "ZXBoolArray.h"
#import "ZXAztecDecoder.h"
#import "ZXAztecDecoderTest.h"

@implementation ZXAztecDecoderTest

- (void)testAztecResult {
  ZXBitMatrix *matrix = [ZXBitMatrix parse:@"X X X X X     X X X       X X X     X X X     \n"
                         "X X X     X X X     X X X X     X X X     X X \n"
                         "  X   X X       X   X   X X X X     X     X X \n"
                         "  X   X X     X X     X     X   X       X   X \n"
                         "  X X   X X         X               X X     X \n"
                         "  X X   X X X X X X X X X X X X X X X     X   \n"
                         "  X X X X X                       X   X X X   \n"
                         "  X   X   X   X X X X X X X X X   X X X   X X \n"
                         "  X   X X X   X               X   X X       X \n"
                         "  X X   X X   X   X X X X X   X   X X X X   X \n"
                         "  X X   X X   X   X       X   X   X   X X X   \n"
                         "  X   X   X   X   X   X   X   X   X   X   X   \n"
                         "  X X X   X   X   X       X   X   X X   X X   \n"
                         "  X X X X X   X   X X X X X   X   X X X   X X \n"
                         "X X   X X X   X               X   X   X X   X \n"
                         "  X       X   X X X X X X X X X   X   X     X \n"
                         "  X X   X X                       X X   X X   \n"
                         "  X X X   X X X X X X X X X X X X X X   X X   \n"
                         "X     X     X     X X   X X               X X \n"
                         "X   X X X X X   X X X X X     X   X   X     X \n"
                         "X X X   X X X X           X X X       X     X \n"
                         "X X     X X X     X X X X     X X X     X X   \n"
                         "    X X X     X X X       X X X     X X X X   \n"
                                 setString:@"X " unsetString:@"  "];
  ZXAztecDetectorResult *r = [[ZXAztecDetectorResult alloc] initWithBits:matrix points:nil compact:NO nbDatablocks:30 nbLayers:2];
  ZXDecoderResult *res = [[[ZXAztecDecoder alloc] init] decode:r error:nil];
  XCTAssertEqualObjects(@"88888TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT", res.text);
  int expectedBytes[23] = {
    -11, 85, 85, 117, 107, 90, -42, -75, -83, 107,
    90, -42, -75, -83, 107, 90, -42, -75, -83, 107,
    90, -42, -80
  };
  for(int i = 0; i < 23; i++) {
    XCTAssertEqual(expectedBytes[i], res.rawBytes.array[i], @"Failed at %d", i);
  }
  XCTAssertEqual(180, res.numBits);
}

- (void)testDecodeTooManyErrors {
  ZXBitMatrix *matrix = [ZXBitMatrix parse:@""
                         "X X . X . . . X X . . . X . . X X X . X . X X X X X . \n"
                         "X X . . X X . . . . . X X . . . X X . . . X . X . . X \n"
                         "X . . . X X . . X X X . X X . X X X X . X X . . X . . \n"
                         ". . . . X . X X . . X X . X X . X . X X X X . X . . X \n"
                         "X X X . . X X X X X . . . . . X X . . . X . X . X . X \n"
                         "X X . . . . . . . . X . . . X . X X X . X . . X . . . \n"
                         "X X . . X . . . . . X X . . . . . X . . . . X . . X X \n"
                         ". . . X . X . X . . . . . X X X X X X . . . . . . X X \n"
                         "X . . . X . X X X X X X . . X X X . X . X X X X X X . \n"
                         "X . . X X X . X X X X X X X X X X X X X . . . X . X X \n"
                         ". . . . X X . . . X . . . . . . . X X . . . X X . X . \n"
                         ". . . X X X . . X X . X X X X X . X . . X . . . . . . \n"
                         "X . . . . X . X . X . X . . . X . X . X X . X X . X X \n"
                         "X . X . . X . X . X . X . X . X . X . . . . . X . X X \n"
                         "X . X X X . . X . X . X . . . X . X . X X X . . . X X \n"
                         "X X X X X X X X . X . X X X X X . X . X . X . X X X . \n"
                         ". . . . . . . X . X . . . . . . . X X X X . . . X X X \n"
                         "X X . . X . . X . X X X X X X X X X X X X X . . X . X \n"
                         "X X X . X X X X . . X X X X . . X . . . . X . . X X X \n"
                         ". . . . X . X X X . . . . X X X X . . X X X X . . . . \n"
                         ". . X . . X . X . . . X . X X . X X . X . . . X . X . \n"
                         "X X . . X . . X X X X X X X . . X . X X X X X X X . . \n"
                         "X . X X . . X X . . . . . X . . . . . . X X . X X X . \n"
                         "X . . X X . . X X . X . X . . . . X . X . . X . . X . \n"
                         "X . X . X . . X . X X X X X X X X . X X X X . . X X . \n"
                         "X X X X . . . X . . X X X . X X . . X . . . . X X X . \n"
                         "X X . X . X . . . X . X . . . . X X . X . . X X . . . \n"
                                 setString:@"X " unsetString:@". "];
  ZXAztecDetectorResult *r = [[ZXAztecDetectorResult alloc] initWithBits:matrix points:nil compact:YES nbDatablocks:16 nbLayers:4];
  ZXDecoderResult *res = [[[ZXAztecDecoder alloc] init] decode:r error:nil];
  XCTAssertNil(res);
}

- (void)testDecodeTooManyErrors2 {
  ZXBitMatrix *matrix = [ZXBitMatrix parse:@""
                         ". X X . . X . X X . . . X . . X X X . . . X X . X X . \n"
                         "X X . X X . . X . . . X X . . . X X . X X X . X . X X \n"
                         ". . . . X . . . X X X . X X . X X X X . X X . . X . . \n"
                         "X . X X . . X . . . X X . X X . X . X X . . . . . X . \n"
                         "X X . X . . X . X X . . . . . X X . . . . . X . . . X \n"
                         "X . . X . . . . . . X . . . X . X X X X X X X . . . X \n"
                         "X . . X X . . X . . X X . . . . . X . . . . . X X X . \n"
                         ". . X X X X . X . . . . . X X X X X X . . . . . . X X \n"
                         "X . . . X . X X X X X X . . X X X . X . X X X X X X . \n"
                         "X . . X X X . X X X X X X X X X X X X X . . . X . X X \n"
                         ". . . . X X . . . X . . . . . . . X X . . . X X . X . \n"
                         ". . . X X X . . X X . X X X X X . X . . X . . . . . . \n"
                         "X . . . . X . X . X . X . . . X . X . X X . X X . X X \n"
                         "X . X . . X . X . X . X . X . X . X . . . . . X . X X \n"
                         "X . X X X . . X . X . X . . . X . X . X X X . . . X X \n"
                         "X X X X X X X X . X . X X X X X . X . X . X . X X X . \n"
                         ". . . . . . . X . X . . . . . . . X X X X . . . X X X \n"
                         "X X . . X . . X . X X X X X X X X X X X X X . . X . X \n"
                         "X X X . X X X X . . X X X X . . X . . . . X . . X X X \n"
                         ". . X X X X X . X . . . . X X X X . . X X X . X . X . \n"
                         ". . X X . X . X . . . X . X X . X X . . . . X X . . . \n"
                         "X . . . X . X . X X X X X X . . X . X X X X X . X . . \n"
                         ". X . . . X X X . . . . . X . . . . . X X X X X . X . \n"
                         "X . . X . X X X X . X . X . . . . X . X X . X . . X . \n"
                         "X . . . X X . X . X X X X X X X X . X X X X . . X X . \n"
                         ". X X X X . . X . . X X X . X X . . X . . . . X X X . \n"
                         "X X . . . X X . . X . X . . . . X X . X . . X . X . X \n"
                                 setString:@"X " unsetString:@". "];
  ZXAztecDetectorResult *r = [[ZXAztecDetectorResult alloc] initWithBits:matrix points:nil compact:YES nbDatablocks:16 nbLayers:4];
  ZXDecoderResult *res = [[[ZXAztecDecoder alloc] init] decode:r error:nil];
  XCTAssertNil(res);
}

- (void)testRawBytes {
  ZXBoolArray *bool0 = [[ZXBoolArray alloc] initWithLength:0];
  ZXBoolArray *bool1 = [[ZXBoolArray alloc] initWithLength:1 values:1];
  ZXBoolArray *bool7 = [[ZXBoolArray alloc] initWithLength:7 values:1, 0, 1, 0, 1, 0, 1];
  ZXBoolArray *bool8 = [[ZXBoolArray alloc] initWithLength:8 values:1, 0, 1, 0, 1, 0, 1, 0];
  ZXBoolArray *bool9 = [[ZXBoolArray alloc] initWithLength:9 values:1, 0, 1, 0, 1, 0, 1, 0, 1];
  ZXBoolArray *bool16 = [[ZXBoolArray alloc] initWithLength:16 values:0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1];
  
  ZXByteArray *byte0actual = [ZXAztecDecoder convertBoolArrayToByteArray:bool0];
  ZXByteArray *byte1actual = [ZXAztecDecoder convertBoolArrayToByteArray:bool1];
  ZXByteArray *byte7actual = [ZXAztecDecoder convertBoolArrayToByteArray:bool7];
  ZXByteArray *byte8actual = [ZXAztecDecoder convertBoolArrayToByteArray:bool8];
  ZXByteArray *byte9actual = [ZXAztecDecoder convertBoolArrayToByteArray:bool9];
  ZXByteArray *byte16actual = [ZXAztecDecoder convertBoolArrayToByteArray:bool16];
  
  ZXByteArray *byte0expected = [[ZXByteArray alloc] initWithLength:0];
  ZXByteArray *byte1expected = [[ZXByteArray alloc] initWithLength:1 bytes:-128];
  ZXByteArray *byte7expected = [[ZXByteArray alloc] initWithLength:1 bytes:-86];
  ZXByteArray *byte8expected = [[ZXByteArray alloc] initWithLength:1 bytes:-86];
  ZXByteArray *byte9expected = [[ZXByteArray alloc] initWithLength:2 bytes:-86, -128];
  ZXByteArray *byte16expected = [[ZXByteArray alloc] initWithLength:2 bytes:99, -63];
  
  [self assertEqualByteArrays:byte0actual expected:byte0expected];
  [self assertEqualByteArrays:byte1actual expected:byte1expected];
  [self assertEqualByteArrays:byte7actual expected:byte7expected];
  [self assertEqualByteArrays:byte8actual expected:byte8expected];
  [self assertEqualByteArrays:byte9actual expected:byte9expected];
  [self assertEqualByteArrays:byte16actual expected:byte16expected];
}

- (void)assertEqualByteArrays:(ZXByteArray *)actual expected:(ZXByteArray *)expected {
  XCTAssertEqual(actual.length, expected.length);
  for(int i = 0; i < actual.length; i++) {
    XCTAssertEqual(actual.array[i], expected.array[i], @"Failed at %d", i);
  }
}

@end

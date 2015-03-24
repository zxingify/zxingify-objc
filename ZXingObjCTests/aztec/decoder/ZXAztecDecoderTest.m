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

#import "ZXBitMatrix.h"
#import "ZXAztecDecoder.h"
#import "ZXAztecDecoderTest.h"

@implementation ZXAztecDecoderTest

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

@end

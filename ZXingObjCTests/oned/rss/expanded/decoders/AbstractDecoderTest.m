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

#import "AbstractDecoderTest.h"
#import "ZXBinaryUtil.h"

const NSString *numeric_10                     = @"..X..XX";
const NSString *numeric_12                     = @"..X.X.X";
const NSString *numeric_1FNC1                  = @"..XXX.X";
//const NSString *numeric_FNC11                  = @"XXX.XXX";

const NSString *numeric2alpha                  = @"....";

const NSString *alpha_A                        = @"X.....";
const NSString *alpha_FNC1                     = @".XXXX";
const NSString *alpha2numeric                  = @"...";
const NSString *alpha2isoiec646                = @"..X..";

const NSString *i646_B                         = @"X.....X";
const NSString *i646_C                         = @"X....X.";
const NSString *i646_FNC1                      = @".XXXX";
const NSString *isoiec646_2alpha               = @"..X..";

const NSString *compressedGtin_900123456798908 = @".........X..XXX.X.X.X...XX.XXXXX.XXXX.X.";
const NSString *compressedGtin_900000000000008 = @"........................................";

const NSString *compressed15bitWeight_1750     = @"....XX.XX.X.XX.";
const NSString *compressed15bitWeight_11750    = @".X.XX.XXXX..XX.";
const NSString *compressed15bitWeight_0        = @"...............";

const NSString *compressed20bitWeight_1750     = @".........XX.XX.X.XX.";

const NSString *compressedDate_March_12th_2010 = @"....XXXX.X..XX..";
const NSString *compressedDate_End             = @"X..X.XX.........";

@implementation AbstractDecoderTest

- (void)assertCorrectBinaryString:(NSString *)binaryString expectedNumber:(NSString *)expectedNumber error:(NSError **)error {
  ZXBitArray *binary = [ZXBinaryUtil buildBitArrayFromStringWithoutSpaces:binaryString];
  ZXAbstractExpandedDecoder *decoder = [ZXAbstractExpandedDecoder createDecoder:binary];
  NSString *result = [decoder parseInformationWithError:error];
  if (!result) {
    return;
  }
  XCTAssertEqualObjects(expectedNumber, result);
}

@end

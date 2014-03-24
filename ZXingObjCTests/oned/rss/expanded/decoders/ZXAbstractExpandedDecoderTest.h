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

extern const NSString *numeric_10;
extern const NSString *numeric_12;
extern const NSString *numeric_1FNC1;
//extern const NSString *numeric_FNC11;

extern const NSString *numeric2alpha;

extern const NSString *alpha_A;
extern const NSString *alpha_FNC1;
extern const NSString *alpha2numeric;
extern const NSString *alpha2isoiec646;

extern const NSString *i646_B;
extern const NSString *i646_C;
extern const NSString *i646_FNC1;
extern const NSString *isoiec646_2alpha;

extern const NSString *compressedGtin_900123456798908;
extern const NSString *compressedGtin_900000000000008;

extern const NSString *compressed15bitWeight_1750;
extern const NSString *compressed15bitWeight_11750;
extern const NSString *compressed15bitWeight_0;

extern const NSString *compressed20bitWeight_1750;

extern const NSString *compressedDate_March_12th_2010;
extern const NSString *compressedDate_End;

@interface ZXAbstractExpandedDecoderTest : XCTestCase

- (void)assertCorrectBinaryString:(NSString *)binaryString expectedNumber:(NSString *)expectedNumber error:(NSError **)error;

@end

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

#import "ZXDataMatrixErrorCorrection.h"
#import "ZXDataMatrixErrorCorrectionTestCase.h"
#import "ZXHighLevelEncoder.h"
#import "ZXHighLevelEncodeTestCase.h"
#import "ZXSymbolInfo.h"

@implementation ZXDataMatrixErrorCorrectionTestCase

- (void)testRS {
  //Sample from Annexe R in ISO/IEC 16022:2000(E)
  const char cw1[4] = {142, 164, 186, NULL};
  ZXSymbolInfo *symbolInfo = [ZXSymbolInfo lookup:3];
  NSString *s = [ZXDataMatrixErrorCorrection encodeECC200:[NSString stringWithCString:cw1 encoding:NSISOLatin1StringEncoding] symbolInfo:symbolInfo];
  STAssertEqualObjects([ZXHighLevelEncodeTestCase visualize:s], @"142 164 186 114 25 5 88 102", @"");

  //"A" encoded (ASCII encoding + 2 padding characters)
  const char cw2[4] = {66, 129, 70, NULL};
  s = [ZXDataMatrixErrorCorrection encodeECC200:[NSString stringWithCString:cw2 encoding:NSISOLatin1StringEncoding] symbolInfo:symbolInfo];
  STAssertEqualObjects([ZXHighLevelEncodeTestCase visualize:s], @"66 129 70 138 234 82 82 95", @"");
}

@end

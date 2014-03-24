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

#import "ZXDataMatrixErrorCorrectionTestCase.h"
#import "ZXDataMatrixHighLevelEncodeTestCase.h"

@implementation ZXDataMatrixErrorCorrectionTestCase

- (void)testRS {
  //Sample from Annexe R in ISO/IEC 16022:2000(E)
  const unichar cw1[3] = {142, 164, 186};
  ZXDataMatrixSymbolInfo *symbolInfo = [ZXDataMatrixSymbolInfo lookup:3];
  NSString *s = [ZXDataMatrixErrorCorrection encodeECC200:[NSString stringWithCharacters:cw1 length:3] symbolInfo:symbolInfo];
  XCTAssertEqualObjects(@"142 164 186 114 25 5 88 102", [ZXDataMatrixHighLevelEncodeTestCase visualize:s]);

  //"A" encoded (ASCII encoding + 2 padding characters)
  const unichar cw2[3] = {66, 129, 70};
  s = [ZXDataMatrixErrorCorrection encodeECC200:[NSString stringWithCharacters:cw2 length:3] symbolInfo:symbolInfo];
  XCTAssertEqualObjects(@"66 129 70 138 234 82 82 95", [ZXDataMatrixHighLevelEncodeTestCase visualize:s]);
}

@end

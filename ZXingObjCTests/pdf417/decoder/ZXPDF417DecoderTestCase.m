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

#import "ZXPDF417DecoderTestCase.h"
#import "ZXPDF417DecodedBitStreamParser.h"
#import "ZXPDF417ResultMetadata.h"

@implementation ZXPDF417DecoderTestCase

// Tests the first sample given in ISO/IEC 15438:2015(E) - Annex H.4
- (void)testStandardSample1 {
  ZXPDF417ResultMetadata *resultMetadata = [[ZXPDF417ResultMetadata alloc] init];
  ZXIntArray *sampleCodes = [[ZXIntArray alloc] initWithInts: 20, 928, 111, 100, 17, 53, 923, 1, 111, 104,
                             923, 3, 64, 416, 34, 923, 4, 258, 446, 67,
                             // we should never reach these
                             1000, 1000, 1000, -1];
  [ZXPDF417DecodedBitStreamParser decodeMacroBlock:sampleCodes codeIndex:2 resultMetadata:resultMetadata];

  XCTAssertEqual(0, resultMetadata.segmentIndex);
  XCTAssertEqualObjects(@"ARBX", resultMetadata.fileId);
  XCTAssertFalse(resultMetadata.lastSegment);
  XCTAssertEqual(4, resultMetadata.segmentCount);
  XCTAssertEqualObjects(@"CEN BE", resultMetadata.sender);
  XCTAssertEqualObjects(@"ISO CH", resultMetadata.addressee);

  NSArray *optionalData = resultMetadata.optionalData;
  XCTAssertEqual(1, [optionalData[0] intValue], @"first element of optional array should be the first field identifier");
  XCTAssertEqual(67, [optionalData[optionalData.count - 1] intValue], @"last element of optional array should be the last codeword of the last field");
}

@end

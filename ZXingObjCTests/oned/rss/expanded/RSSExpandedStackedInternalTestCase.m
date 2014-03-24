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

#import "RSSExpandedStackedInternalTestCase.h"
#import "TestCaseUtil.h"

@interface ZXRSSExpandedReader (PrivateMethods)

- (NSMutableArray *)decodeRow2pairs:(int)rowNumber row:(ZXBitArray *)row error:(NSError **)error ;
- (ZXResult *)constructResult:(NSMutableArray *)pairs error:(NSError **)error;

@end

@implementation RSSExpandedStackedInternalTestCase

- (void)testDecodingRowByRow {
  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];

  ZXBinaryBitmap *binaryMap = [TestCaseUtil binaryBitmap:@"Resources/blackbox/rssexpandedstacked-2/1000.png"];

	int firstRowNumber = [binaryMap height] / 3;
  NSError *error = nil;
  ZXBitArray *firstRow = [binaryMap blackRow:firstRowNumber row:nil error:&error];
  XCTAssertNil(error, @"%@", [error description]);

  if ([rssExpandedReader decodeRow2pairs:firstRowNumber row:firstRow error:&error]) {
    XCTFail(@"Not found error expected");
  }

  XCTAssertEqual(1, [[rssExpandedReader rows] count]);
  ZXExpandedRow *firstExpandedRow = rssExpandedReader.rows[0];
  XCTAssertEqual(firstRowNumber, firstExpandedRow.rowNumber);

  XCTAssertEqual(2, [firstExpandedRow.pairs count]);

  [firstExpandedRow.pairs[1] finderPattern].startEnd.array[1] = 0;

	int secondRowNumber = 2 * [binaryMap height] / 3;
  ZXBitArray *secondRow = [binaryMap blackRow:secondRowNumber row:nil error:nil];
  [secondRow reverse];

  NSMutableArray* totalPairs = [rssExpandedReader decodeRow2pairs:secondRowNumber row:secondRow error:nil];

  ZXResult *result = [rssExpandedReader constructResult:totalPairs error:nil];
  XCTAssertEqualObjects(@"(01)98898765432106(3202)012345(15)991231", result.text);
}

- (void)testCompleteDecoding {
  ZXOneDReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];

  ZXBinaryBitmap *binaryMap = [TestCaseUtil binaryBitmap:@"Resources/blackbox/rssexpandedstacked-2/1000.png"];

  ZXResult *result = [rssExpandedReader decode:binaryMap error:nil];
  XCTAssertEqualObjects(@"(01)98898765432106(3202)012345(15)991231", result.text);
}

@end

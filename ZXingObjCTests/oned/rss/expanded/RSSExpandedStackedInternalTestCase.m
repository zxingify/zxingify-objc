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
#import "ZXRSSExpandedReader.h"
#import "ZXExpandedPair.h"
#import "ZXExpandedRow.h"
#import "ZXRSSFinderPattern.h"
#import "ZXImage.h"
#import "ZXGlobalHistogramBinarizer.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXBinaryBitmap.h"
#import "ZXResult.h"

@implementation RSSExpandedStackedInternalTestCase

- (void)testDecodingRowByRow {
  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];

  ZXBinaryBitmap *binaryMap = [TestCaseUtil binaryBitmap:@"Resources/blackbox/rssexpandedstacked-2/1000.png"];

	int firstRowNumber = [binaryMap height] / 3;
  NSError *error = nil;
  ZXBitArray *firstRow = [binaryMap blackRow:firstRowNumber row:nil error:&error];
  STAssertNil(error, [error description]);

  if ([rssExpandedReader decodeRow2pairs:firstRowNumber row:firstRow]) {
    STFail(@"Not found error expected");
  }

  STAssertEquals([[rssExpandedReader rows] count], (NSUInteger)1, @"the first row not recognized");
  ZXExpandedRow *firstExpandedRow = [rssExpandedReader.rows objectAtIndex:0];
  STAssertEquals(firstExpandedRow.rowNumber, firstRowNumber, @"the first row number doesn't match");

  STAssertEquals([firstExpandedRow.pairs count], (NSUInteger)2, @"wrong number if pairs in the first row");

  [[[firstExpandedRow.pairs objectAtIndex:1] finderPattern].startEnd replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]];

	int secondRowNumber = 2 * [binaryMap height] / 3;
  error = nil;
  ZXBitArray *secondRow = [binaryMap blackRow:secondRowNumber row:nil error:&error];
  STAssertNil(error, [error description]);
  [secondRow reverse];

  NSMutableArray* totalPairs = [rssExpandedReader decodeRow2pairs:secondRowNumber row:secondRow];
  error = nil;

  ZXResult *result = [rssExpandedReader constructResult:totalPairs error:&error];
  STAssertNil(error, [error description]);
  STAssertEqualObjects(result.text, @"(01)98898765432106(3202)012345(15)991231", @"wrong result");
}

- (void)testCompleteDecoding {
  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];

  ZXBinaryBitmap *binaryMap = [TestCaseUtil binaryBitmap:@"Resources/blackbox/rssexpandedstacked-2/1000.png"];

  NSError *error = nil;
  ZXResult *result = [rssExpandedReader decode:binaryMap error:&error];
  STAssertNil(error, [error description]);
  STAssertEqualObjects(result.text, @"(01)98898765432106(3202)012345(15)991231", @"wrong result");
}

@end

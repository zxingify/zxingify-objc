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

#import "RSSExpandedInternalTestCase.h"

@interface ZXRSSExpandedReader (PrivateMethods)

- (ZXResult *)constructResult:(NSMutableArray *)pairs error:(NSError **)error;
- (ZXExpandedPair *)retrieveNextPair:(ZXBitArray *)row previousPairs:(NSMutableArray *)previousPairs rowNumber:(int)rowNumber;

@end

@implementation RSSExpandedInternalTestCase

- (void)testFindFinderPatterns {
  NSString *path = @"Resources/blackbox/rssexpanded-1/2.png";
  ZXImage *image = [[ZXImage alloc] initWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:path withExtension:nil]];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  int rowNumber = binaryMap.height / 2;
  ZXBitArray *row = [binaryMap blackRow:rowNumber row:nil error:nil];
  NSMutableArray *previousPairs = [NSMutableArray array];

  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];
  ZXExpandedPair *pair1 = [rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber];
  [previousPairs addObject:pair1];
  ZXRSSFinderPattern *finderPattern = pair1.finderPattern;
  XCTAssertNotNil(finderPattern, @"Expected finderPattern to be non-nil");
  XCTAssertEqual(finderPattern.value, 0, @"Expected finderPattern to equal 0");

  ZXExpandedPair *pair2 = [rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber];
  [previousPairs addObject:pair2];
  finderPattern = pair2.finderPattern;
  XCTAssertNotNil(finderPattern, @"Expected finderPattern to be non-nil");
  XCTAssertEqual(finderPattern.value, 1, @"Expected finderPattern to equal 1");

  ZXExpandedPair *pair3 = [rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber];
  [previousPairs addObject:pair3];
  finderPattern = pair3.finderPattern;
  XCTAssertNotNil(finderPattern, @"Expected finderPattern to be non-nil");
  XCTAssertEqual(finderPattern.value, 1, @"Expected finderPattern to equal 1");

  if ([rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber]) {
    //   the previous was the last pair
    XCTFail(@"Error expected");
  }
}

- (void)testRetrieveNextPairPatterns {
  NSString *path = @"Resources/blackbox/rssexpanded-1/3.png";
  ZXImage *image = [[ZXImage alloc] initWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:path withExtension:nil]];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  int rowNumber = binaryMap.height / 2;
  ZXBitArray *row = [binaryMap blackRow:rowNumber row:nil error:nil];
  NSMutableArray *previousPairs = [NSMutableArray array];

  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];
  ZXExpandedPair *pair1 = [rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber];
  [previousPairs addObject:pair1];
  ZXRSSFinderPattern *finderPattern = pair1.finderPattern;
  XCTAssertNotNil(finderPattern, @"Expected finderPattern to be non-nil");
  XCTAssertEqual(finderPattern.value, 0, @"Expected finderPattern to equal 0");

  ZXExpandedPair *pair2 = [rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber];
  [previousPairs addObject:pair2];
  finderPattern = pair2.finderPattern;
  XCTAssertNotNil(finderPattern, @"Expected finderPattern to be non-nil");
  XCTAssertEqual(finderPattern.value, 0, @"Expected finderPattern to equal 0");
}

- (void)testDecodeCheckCharacter {
  NSString *path = @"Resources/blackbox/rssexpanded-1/3.png";
  ZXImage *image = [[ZXImage alloc] initWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:path withExtension:nil]];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  ZXBitArray *row = [binaryMap blackRow:binaryMap.height / 2 row:nil error:nil];

  ZXIntArray *startEnd = [[ZXIntArray alloc] initWithInts:145, 243, -1];//image pixels where the A1 pattern starts (at 124) and ends (at 214)
  int value = 0;// A
  ZXRSSFinderPattern *finderPatternA1 = [[ZXRSSFinderPattern alloc] initWithValue:value startEnd:startEnd start:startEnd.array[0] end:startEnd.array[1] rowNumber:(int)image.height / 2];
  //{1, 8, 4, 1, 1};
  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];
  ZXDataCharacter *dataCharacter = [rssExpandedReader decodeDataCharacter:row pattern:finderPatternA1 isOddPattern:YES leftChar:YES];

  XCTAssertEqual(dataCharacter.value, 98, @"Expected dataCharacter.value to equal 98");
}

- (void)testDecodeDataCharacter {
  NSString *path = @"Resources/blackbox/rssexpanded-1/3.png";
  ZXImage *image = [[ZXImage alloc] initWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:path withExtension:nil]];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  ZXBitArray *row = [binaryMap blackRow:binaryMap.height / 2 row:nil error:nil];

  ZXIntArray *startEnd = [[ZXIntArray alloc] initWithInts:145, 243, -1];//image pixels where the A1 pattern starts (at 124) and ends (at 214)
  int value = 0;// A
  ZXRSSFinderPattern *finderPatternA1 = [[ZXRSSFinderPattern alloc] initWithValue:value startEnd:startEnd start:startEnd.array[0] end:startEnd.array[1] rowNumber:(int)image.height / 2];
  //{1, 8, 4, 1, 1};
  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];
  ZXDataCharacter *dataCharacter = [rssExpandedReader decodeDataCharacter:row pattern:finderPatternA1 isOddPattern:YES leftChar:NO];

  XCTAssertEqual(dataCharacter.value, 19, @"Expected dataCharacter.value to equal 19");
  XCTAssertEqual(dataCharacter.checksumPortion, 1007, @"Expected dataCharacter.checksumPortion to equal 1007");
}

@end

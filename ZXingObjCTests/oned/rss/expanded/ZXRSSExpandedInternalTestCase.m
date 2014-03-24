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

#import "ZXBitArrayBuilder.h"
#import "ZXRSSExpandedInternalTestCase.h"
#import "ZXRSSExpandedPair.h"

@interface ZXRSSExpandedReader (PrivateMethods)

- (ZXResult *)constructResult:(NSMutableArray *)pairs error:(NSError **)error;
- (ZXRSSExpandedPair *)retrieveNextPair:(ZXBitArray *)row previousPairs:(NSMutableArray *)previousPairs rowNumber:(int)rowNumber;

@end

@implementation ZXRSSExpandedInternalTestCase

- (void)testFindFinderPatterns {
  ZXImage *image = [self readImage:@"2.png"];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  int rowNumber = binaryMap.height / 2;
  ZXBitArray *row = [binaryMap blackRow:rowNumber row:nil error:nil];
  NSMutableArray *previousPairs = [NSMutableArray array];

  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];
  ZXRSSExpandedPair *pair1 = [rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber];
  [previousPairs addObject:pair1];
  ZXRSSFinderPattern *finderPattern = pair1.finderPattern;
  XCTAssertNotNil(finderPattern);
  XCTAssertEqual(0, finderPattern.value);

  ZXRSSExpandedPair *pair2 = [rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber];
  [previousPairs addObject:pair2];
  finderPattern = pair2.finderPattern;
  XCTAssertNotNil(finderPattern);
  XCTAssertEqual(1, finderPattern.value);

  ZXRSSExpandedPair *pair3 = [rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber];
  [previousPairs addObject:pair3];
  finderPattern = pair3.finderPattern;
  XCTAssertNotNil(finderPattern);
  XCTAssertEqual(1, finderPattern.value);

  if ([rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber]) {
    //   the previous was the last pair
    XCTFail(@"Error expected");
  }
}

- (void)testRetrieveNextPairPatterns {
  ZXImage *image = [self readImage:@"3.png"];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  int rowNumber = binaryMap.height / 2;
  ZXBitArray *row = [binaryMap blackRow:rowNumber row:nil error:nil];
  NSMutableArray *previousPairs = [NSMutableArray array];

  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];
  ZXRSSExpandedPair *pair1 = [rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber];
  [previousPairs addObject:pair1];
  ZXRSSFinderPattern *finderPattern = pair1.finderPattern;
  XCTAssertNotNil(finderPattern);
  XCTAssertEqual(0, finderPattern.value);

  ZXRSSExpandedPair *pair2 = [rssExpandedReader retrieveNextPair:row previousPairs:previousPairs rowNumber:rowNumber];
  [previousPairs addObject:pair2];
  finderPattern = pair2.finderPattern;
  XCTAssertNotNil(finderPattern);
  XCTAssertEqual(0, finderPattern.value);
}

- (void)testDecodeCheckCharacter {
  ZXImage *image = [self readImage:@"3.png"];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  ZXBitArray *row = [binaryMap blackRow:binaryMap.height / 2 row:nil error:nil];

  ZXIntArray *startEnd = [[ZXIntArray alloc] initWithInts:145, 243, -1];//image pixels where the A1 pattern starts (at 124) and ends (at 214)
  int value = 0;// A
  ZXRSSFinderPattern *finderPatternA1 = [[ZXRSSFinderPattern alloc] initWithValue:value startEnd:startEnd start:startEnd.array[0] end:startEnd.array[1] rowNumber:(int)image.height / 2];
  //{1, 8, 4, 1, 1};
  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];
  ZXRSSDataCharacter *dataCharacter = [rssExpandedReader decodeDataCharacter:row pattern:finderPatternA1 isOddPattern:YES leftChar:YES];

  XCTAssertEqual(98, dataCharacter.value);
}

- (void)testDecodeDataCharacter {
  ZXImage *image = [self readImage:@"3.png"];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  ZXBitArray *row = [binaryMap blackRow:binaryMap.height / 2 row:nil error:nil];

  ZXIntArray *startEnd = [[ZXIntArray alloc] initWithInts:145, 243, -1];//image pixels where the A1 pattern starts (at 124) and ends (at 214)
  int value = 0;// A
  ZXRSSFinderPattern *finderPatternA1 = [[ZXRSSFinderPattern alloc] initWithValue:value startEnd:startEnd start:startEnd.array[0] end:startEnd.array[1] rowNumber:(int)image.height / 2];
  //{1, 8, 4, 1, 1};
  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];
  ZXRSSDataCharacter *dataCharacter = [rssExpandedReader decodeDataCharacter:row pattern:finderPatternA1 isOddPattern:YES leftChar:NO];

  XCTAssertEqual(19, dataCharacter.value);
  XCTAssertEqual(1007, dataCharacter.checksumPortion);
}

- (ZXImage *)readImage:(NSString *)fileName {
  NSString *path = [@"Resources/blackbox/rssexpanded-1/" stringByAppendingString:fileName];
  return [[ZXImage alloc] initWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:path withExtension:nil]];
}

@end

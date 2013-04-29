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

#import "RSSExpandedImage2resultTestCase.h"
#import "ZXBinaryBitmap.h"
#import "ZXBitArrayBuilder.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXExpandedProductParsedResult.h"
#import "ZXGlobalHistogramBinarizer.h"
#import "ZXImage.h"
#import "ZXResultParser.h"
#import "ZXRSSExpandedReader.h"

@interface RSSExpandedImage2resultTestCase ()

- (void)assertCorrectImage2result:(NSString *)path expected:(ZXExpandedProductParsedResult *)expected;

@end

@implementation RSSExpandedImage2resultTestCase

- (void)testDecodeRow2result_2 {
  // (01)90012345678908(3103)001750
  NSString *path = @"Resources/blackbox/rssexpanded-1/2.png";
  ZXExpandedProductParsedResult *expected =
  [ZXExpandedProductParsedResult expandedProductParsedResultWithRawText:@"(01)90012345678908(3103)001750" productID:@"90012345678908" sscc:nil lotNumber:nil productionDate:nil
                                                          packagingDate:nil bestBeforeDate:nil expirationDate:nil weight:@"001750"
                                                             weightType:KILOGRAM weightIncrement:@"3" price:nil priceIncrement:nil
                                                          priceCurrency:nil uncommonAIs:[NSMutableDictionary dictionary]];

  [self assertCorrectImage2result:path expected:expected];
}

- (void)assertCorrectImage2result:(NSString *)path expected:(ZXExpandedProductParsedResult *)expected {
  ZXImage *image = [[ZXImage alloc] initWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:path withExtension:nil]];
  ZXBinaryBitmap *binaryMap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[ZXCGImageLuminanceSource alloc] initWithZXImage:image]]];
  int rowNumber = binaryMap.height / 2;
  ZXBitArray *row = [binaryMap blackRow:rowNumber row:nil error:nil];

  NSError *error;
  ZXRSSExpandedReader *rssExpandedReader = [[ZXRSSExpandedReader alloc] init];
  ZXResult *theResult = [rssExpandedReader decodeRow:rowNumber row:row hints:nil error:&error];
  if (!theResult) {
    STFail([error description]);
    return;
  }

  STAssertEquals(theResult.barcodeFormat, kBarcodeFormatRSSExpanded, @"Expected format to be kBarcodeFormatRSSExpanded");

  ZXParsedResult *result = [ZXResultParser parseResult:theResult];

  STAssertEqualObjects(result, expected, @"Result does not match expected");
}

@end

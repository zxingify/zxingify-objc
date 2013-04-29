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

#import "ZXBitMatrix.h"
#import "ZXCodaBarWriter.h"
#import "ZXCodaBarWriterTestCase.h"

@implementation ZXCodaBarWriterTestCase

- (void) testEncode {
  // 1001001011 0 110101001 0 101011001 0 110101001 0 101001101 0 110010101 0 1101101011 0
  // 1001001011
  NSString *resultStr = @"0000000000"
    @"1001001011011010100101010110010110101001010100110101100101010110110101101001001011"
    @"0000000000";
  ZXBitMatrix *result = [[[ZXCodaBarWriter alloc] init] encode:@"B515-3/N" format:kBarcodeFormatCodabar width:resultStr.length height:0 error:nil];
  for (int i = 0; i < resultStr.length; i++) {
    STAssertEquals([result getX:i y:0], (BOOL)([resultStr characterAtIndex:i] == '1'), @"Element %d", i);
  }
}

@end

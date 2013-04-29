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
#import "ZXEAN13Writer.h"
#import "ZXEAN13WriterTestCase.h"

@implementation ZXEAN13WriterTestCase

- (void)testEncode {
  NSString *testStr = @"00010100010110100111011001100100110111101001110101010110011011011001000010101110010011101000100101000";
  ZXBitMatrix *result = [[[ZXEAN13Writer alloc] init] encode:@"5901234123457"
                                                                    format:kBarcodeFormatEan13
                                                                     width:testStr.length height:0
                                                                     error:nil];
  for (int i = 0; i < testStr.length; i++) {
    STAssertEquals([result getX:i y:0], (BOOL)([testStr characterAtIndex:i] == '1'), @"Element %d", i);
  }
}

@end

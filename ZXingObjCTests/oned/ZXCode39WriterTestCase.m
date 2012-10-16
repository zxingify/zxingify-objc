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
#import "ZXCode39Writer.h"
#import "ZXCode39WriterTestCase.h"

@implementation ZXCode39WriterTestCase

- (void)testEncode {
  NSString* testStr = @"00010110110100101011010010110101010011011011011010010101010110011010110101001011010101001101101100101010110101101101001000";

  ZXBitMatrix* result = [[[[ZXCode39Writer alloc] init] autorelease] encode:@"K316738"
                                                                     format:kBarcodeFormatCode39
                                                                      width:testStr.length
                                                                     height:0
                                                                      error:nil];

  for (int i = 0; i < testStr.length; i++) {
    STAssertEquals([result getX:i y:0], (BOOL)([testStr characterAtIndex:i] == '1'), @"Element %d", i);
  }
}

@end

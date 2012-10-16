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
#import "ZXITFWriter.h"
#import "ZXITFWriterTestCase.h"

@implementation ZXITFWriterTestCase

- (void)testEncode {
  NSString* testStr = @"000101010100011101110001010001011101110100011100010111010100010111010001000111011100011101010001011101000";

  ZXBitMatrix* result = [[[[ZXITFWriter alloc] init] autorelease] encode:@"0901512038"
                                                                  format:kBarcodeFormatITF
                                                                   width:testStr.length
                                                                  height:0
                                                                   error:nil];

  for (int i = 0; i < testStr.length; i++) {
    STAssertEquals([result getX:i y:0], (BOOL)([testStr characterAtIndex:i] == '1'), @"Element %d", i);
  }
}

@end

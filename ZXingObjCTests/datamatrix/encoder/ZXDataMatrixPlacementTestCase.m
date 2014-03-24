/*
 * Copyright 2013 ZXing authors
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

#import "ZXDataMatrixDebugPlacement.h"
#import "ZXDataMatrixPlacementTestCase.h"

@implementation ZXDataMatrixPlacementTestCase

- (void)testPlacement {
  NSString *codewords = [self unvisualize:@"66 74 78 66 74 78 129 56 35 102 192 96 226 100 156 1 107 221"]; //"AIMAIM" encoded
  ZXDataMatrixDebugPlacement *placement = [[ZXDataMatrixDebugPlacement alloc] initWithCodewords:codewords numcols:12 numrows:12];
  [placement place];
  NSArray *expected = @[
    @"011100001111",
    @"001010101000",
    @"010001010100",
    @"001010100010",
    @"000111000100",
    @"011000010100",
    @"000100001101",
    @"011000010000",
    @"001100001101",
    @"100010010111",
    @"011101011010",
    @"001011001010"];
  NSArray *actual = [placement toBitFieldStringArray];
  for (int i = 0; i < actual.count; i++) {
    XCTAssertEqualObjects(expected[i], actual[i], @"Row %d", i);
  }
}

- (NSString *)unvisualize:(NSString *)visualize {
  NSMutableString *sb = [NSMutableString string];
  for (NSString *token in [visualize componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]) {
    [sb appendFormat:@"%C", (unichar)[token intValue]];
  }
  return [NSString stringWithString:sb];
}

@end

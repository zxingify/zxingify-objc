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

#import "ZXBinaryUtil.h"
#import "ZXBinaryUtilTest.h"

@implementation ZXBinaryUtilTest

- (void)testBuildBitArrayFromString {
  NSString *data = @" ..X..X.. ..XXX... XXXXXXXX ........";
  [self check:data];

  data = @" XXX..X..";
  [self check:data];

  data = @" XX";
  [self check:data];

  data = @" ....XX.. ..XX";
  [self check:data];

  data = @" ....XX.. ..XX..XX ....X.X. ........";
  [self check:data];
}

- (void)check:(NSString *)data {
  ZXBitArray *binary = [ZXBinaryUtil buildBitArrayFromString:data];
  XCTAssertEqualObjects(data, [binary description]);
}

- (void)testBuildBitArrayFromStringWithoutSpaces {
  NSString *data = @" ..X..X.. ..XXX... XXXXXXXX ........";
  [self checkWithoutSpaces:data];

  data = @" XXX..X..";
  [self checkWithoutSpaces:data];

  data = @" XX";
  [self checkWithoutSpaces:data];

  data = @" ....XX.. ..XX";
  [self checkWithoutSpaces:data];

  data = @" ....XX.. ..XX..XX ....X.X. ........";
  [self checkWithoutSpaces:data];
}

- (void)checkWithoutSpaces:(NSString *)data {
  NSString *dataWithoutSpaces = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
  ZXBitArray *binary = [ZXBinaryUtil buildBitArrayFromStringWithoutSpaces:dataWithoutSpaces];
  XCTAssertEqualObjects(data, [binary description]);
}

@end

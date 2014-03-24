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

#import "AI01_3103_DecoderTest.h"

static NSString *header = @"..X..";

@implementation AI01_3103_DecoderTest

- (void)test01_3103_1 {
  NSString *data = [NSString stringWithFormat:@"%@%@%@", header, compressedGtin_900123456798908, compressed15bitWeight_1750];
  NSString *expected = @"(01)90012345678908(3103)001750";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

- (void)test01_3103_2 {
  NSString *data = [NSString stringWithFormat:@"%@%@%@", header, compressedGtin_900000000000008, compressed15bitWeight_0];
  NSString *expected = @"(01)90000000000003(3103)000000";

  [self assertCorrectBinaryString:data expectedNumber:expected error:nil];
}

- (void)test01_3103_invalid {
  NSString *data = [NSString stringWithFormat:@"%@%@%@..", header, compressedGtin_900123456798908, compressed15bitWeight_1750];

  NSError *error;
  [self assertCorrectBinaryString:data expectedNumber:@"" error:&error];
  if (!error || error.code != ZXNotFoundError) {
    XCTFail(@"ZXNotFoundError expected");
  }
}

@end

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

@implementation ZXBinaryUtil

+ (ZXBitArray *)buildBitArrayFromString:(NSString *)data {
  NSString *dotsAndXs = [[data stringByReplacingOccurrencesOfString:@"1" withString:@"X"]
                         stringByReplacingOccurrencesOfString:@"0" withString:@"."];
  ZXBitArray *binary = [[ZXBitArray alloc] initWithSize:(int)[dotsAndXs stringByReplacingOccurrencesOfString:@" " withString:@""].length];
  int counter = 0;

  for (int i = 0; i < dotsAndXs.length; ++i){
    if (i % 9 == 0) { // spaces
      if ([dotsAndXs characterAtIndex:i] != ' ') {
        @throw [NSException exceptionWithName:@"IllegalStateException" reason:@"space expected" userInfo:nil];
      }
      continue;
    }

    unichar currentChar = [dotsAndXs characterAtIndex:i];
    if (currentChar == 'X' || currentChar == 'x') {
      [binary set:counter];
    }
    counter++;
  }
  return binary;
}

+ (ZXBitArray *)buildBitArrayFromStringWithoutSpaces:(NSString *)data {
  NSMutableString *sb = [NSMutableString string];

  NSString *dotsAndXs = [[data stringByReplacingOccurrencesOfString:@"1" withString:@"X"]
                         stringByReplacingOccurrencesOfString:@"0" withString:@"."];

  int current = 0;
  while (current < dotsAndXs.length) {
    [sb appendString:@" "];
    for (int i = 0; i < 8 && current < dotsAndXs.length; ++i){
      [sb appendFormat:@"%C", [dotsAndXs characterAtIndex:current]];
      current++;
    }
  }

  return [self buildBitArrayFromString:sb];
}


@end

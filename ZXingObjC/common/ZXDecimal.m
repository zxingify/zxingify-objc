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

#include "ZXDecimal.h"

@interface ZXDecimal ()

@property (nonatomic, strong) NSString *value;

@end

@implementation ZXDecimal

- (id)initWithValue:(NSString *)value {
  if (self = [super init]) {
    self.value = value;
  }
  return self;
}

+ (ZXDecimal *)decimalWithString:(NSString *)string {
  return [[self alloc] initWithValue:string];
}

+ (ZXDecimal *)decimalWithDecimalNumber:(NSDecimalNumber *)decimalNumber {
  return [self decimalWithString:[decimalNumber stringValue]];
}

- (NSString *)reverseString:(NSString *)string {
  NSUInteger length = [string length];
  unichar *data = malloc(sizeof (unichar) * length);
  int i;

  for (i = 0; i < length / 2; i++) {
    unichar startChar = [string characterAtIndex:i];
    unichar endChar = [string  characterAtIndex:(length - 1) - i];

    data[i] = endChar;
    data[(length - 1) - i] = startChar;
  }

  NSString *reversed = [NSString stringWithCharacters:data length:length];
  free(data);

  return reversed;
}

- (ZXDecimal *)decimalByMultiplyingBy:(ZXDecimal *)number {
  int leftLength = (int) _value.length;
  int rightLength = (int) number.value.length;
  const char *leftChars = [[self reverseString:_value] UTF8String];
  const char *rightChars = [[self reverseString:number.value] UTF8String];

  int length = (int) _value.length + (int) number.value.length;
  char *result = calloc(length, sizeof(char));

  for (int leftIndex = 0; leftIndex < leftLength; leftIndex++) {
    for (int rightIndex = 0; rightIndex < rightLength; rightIndex++) {
      int resultIndex = leftIndex + rightIndex;
      int leftValue = (int) (leftChars[leftIndex] - 48);
      int rightValue = (int) (rightChars[rightIndex] - 48);
      result[resultIndex] = leftValue * rightValue;
      if (((int) result[resultIndex] - 48) > 0) {
        result[resultIndex] -= (int) (result[resultIndex] - 48) / 10;
        result[resultIndex + 1] += (int) (result[resultIndex] - 48) / 10;
      }
    }
  }

  NSMutableString *retVal = [NSMutableString string];
  for (int i = 0; i < length; i++) {
    if (result[i] == 0) {
      [retVal appendString:@"0"];
    } else {
      [retVal appendFormat:@"%d", result[i]];
    }
  }

  retVal = [[self reverseString:retVal] mutableCopy];
  if ([retVal characterAtIndex:0] == 0) {
    retVal = [[retVal substringFromIndex:1] mutableCopy];
  }

  free(result);

  return [ZXDecimal decimalWithString:retVal];
}

- (ZXDecimal *)decimalByAdding:(ZXDecimal *)number {
  // stub
  return [ZXDecimal decimalWithString:number.value];
}

@end

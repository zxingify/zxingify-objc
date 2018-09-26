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
  int length = (int) [string length];
  NSMutableString *data = [NSMutableString string];

  for (int i = 0; i < length; i++) {
    int pos = (length - 1) - i;
    NSString* tmp = [string substringWithRange:NSMakeRange(pos, 1)];
    [data appendString:tmp];
  }

  return data;
}

- (int8_t *)intArrayFromString:(NSString *) string {
  int length = (int)[string length];
  int8_t *result = malloc(length * sizeof(int8_t));
  for (int i = 0; i < length; i++) {
    result[i] = [[string substringWithRange:NSMakeRange(i, 1 )] intValue];
  }
  return result;
}

- (ZXDecimal *)decimalByMultiplyingBy:(ZXDecimal *)number {
  int leftLength = (int) _value.length;
  int rightLength = (int) number.value.length;
  const int8_t *left = [self intArrayFromString:[self reverseString:_value]];
  const int8_t *right = [self intArrayFromString:[self reverseString:number.value]];

  int length = (int) _value.length + (int) number.value.length;
  int8_t *result = calloc(length, sizeof(int8_t));

  for (int leftIndex = 0; leftIndex < leftLength; leftIndex++) {
    for (int rightIndex = 0; rightIndex < rightLength; rightIndex++) {
      int resultIndex = leftIndex + rightIndex;

      int leftValue = left[leftIndex];
      int rightValue = right[rightIndex];

      result[resultIndex] = leftValue * rightValue + (resultIndex >= length ? 0 : result[resultIndex]);

      if (result[resultIndex] > 9) {
        result[resultIndex + 1] = (result[resultIndex] / 10) + (resultIndex + 1 >= length ? 0 : result[resultIndex + 1]);
        result[resultIndex] -= (result[resultIndex] / 10) * 10;
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
  while ([retVal characterAtIndex:0] == 0) {
    retVal = [[retVal substringFromIndex:1] mutableCopy];
  }

  free(result);

  return [ZXDecimal decimalWithString:retVal];
}

- (ZXDecimal *)decimalByAdding:(ZXDecimal *)number {
  int leftLength = (int) _value.length;
  int rightLength = (int) number.value.length;

  const int8_t *left = [self intArrayFromString:[self reverseString:_value]];
  const int8_t *right = [self intArrayFromString:[self reverseString:number.value]];

  int length = rightLength + 1;
  if (leftLength > rightLength) {
    length = leftLength + 1;
  }

  int8_t *result = calloc(length, sizeof(int8_t));

  for (int i = 0; i < length - 1; i++) {
    int leftValue = leftLength >= i ? left[i] : 0;
    int rightValue = rightLength >= i ? right[i] : 0;

    int add = leftValue + rightValue + result[i];
    if (add >= 10) {
      result[i] = (add % 10);
      result[i + 1] = 1;
    } else {
      result[i] = add;
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
  while ([retVal characterAtIndex:0] == 0) {
    retVal = [[retVal substringFromIndex:1] mutableCopy];
  }

  free(result);

  return [ZXDecimal decimalWithString:retVal];
}

@end

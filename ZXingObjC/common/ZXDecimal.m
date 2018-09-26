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

- (ZXDecimal *)decimalByMultiplyingBy:(ZXDecimal *)number {
  // stub
  return [ZXDecimal decimalWithString:number.value];
}

- (ZXDecimal *)decimalByAdding:(ZXDecimal *)number {
  // stub
  return [ZXDecimal decimalWithString:number.value];
}

@end

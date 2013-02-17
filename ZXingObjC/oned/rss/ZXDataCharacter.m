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

#import "ZXDataCharacter.h"

@interface ZXDataCharacter ()

@property (nonatomic, assign) int value;
@property (nonatomic, assign) int checksumPortion;

@end

@implementation ZXDataCharacter

@synthesize value;
@synthesize checksumPortion;

- (id)initWithValue:(int)aValue checksumPortion:(int)aChecksumPortion {
  if (self = [super init]) {
    self.value = aValue;
    self.checksumPortion = aChecksumPortion;
  }

  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%d(%d)", self.value, self.checksumPortion];
}

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[ZXDataCharacter class]]) {
    return NO;
  }

  ZXDataCharacter *that = (ZXDataCharacter *)object;
  return (self.value == that.value) && (self.checksumPortion == that.checksumPortion);
}

- (NSUInteger)hash {
  return self.value ^ self.checksumPortion;
}

@end

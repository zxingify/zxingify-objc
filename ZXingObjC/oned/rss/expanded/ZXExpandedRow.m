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

#import "ZXExpandedRow.h"

@interface ZXExpandedRow ()

@property (nonatomic, retain) NSArray *pairs;
@property (nonatomic, assign) int rowNumber;
@property (nonatomic, assign) BOOL wasReversed;

@end

@implementation ZXExpandedRow

@synthesize rowNumber;
@synthesize wasReversed;
@synthesize pairs;

- (id)initWithPairs:(NSArray *)_pairs rowNumber:(int)_rowNumber wasReversed:(BOOL)_wasReversed {
  if (self = [super init]) {
    self.pairs = [NSArray arrayWithArray:_pairs];
    self.rowNumber = _rowNumber;
    self.wasReversed = _wasReversed;
  }

  return self;
}

- (void)dealloc {
  [pairs release];

  [super dealloc];
}

- (BOOL)isReversed {
  return self.wasReversed;
}

- (BOOL)isEquivalent:(NSArray *)otherPairs {
  return [self.pairs isEqualToArray:otherPairs];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"{%@}", self.pairs];
}

/**
 * Two rows are equal if they contain the same pairs in the same order.
 */
- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[ZXExpandedRow class]]) {
    return NO;
  }
  ZXExpandedRow *that = (ZXExpandedRow *)object;
  return [self.pairs isEqual:that.pairs] && (self.wasReversed == that.wasReversed);
}

- (NSUInteger)hash {
  return self.pairs.hash ^ [NSNumber numberWithBool:self.wasReversed].hash;
}

@end

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

@implementation ZXExpandedRow

@synthesize rowNumber;
@synthesize wasReversed;
@synthesize pairs;

- (id)initWithPairs:(NSArray*)_pairs rowNumber:(int)_rowNumber wasReversed:(BOOL)_wasReversed {
  self = [super init];
  if (self) {
    self.pairs = [NSArray arrayWithArray:_pairs];
    self.rowNumber = _rowNumber;
    self.wasReversed = _wasReversed;
  }
  return self;
}

- (BOOL)isEquivalent:(NSArray *)otherPairs
{
  return [self.pairs isEqual:otherPairs];
}

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[ZXExpandedRow class]])
    return false;

  ZXExpandedRow *that = (ZXExpandedRow *)object;
  return [self.pairs isEqual:that.pairs] && (self.wasReversed == that.wasReversed);
}

- (NSString *)description {
  return [NSString stringWithFormat:@"[%d: %@]", self.rowNumber, self.pairs];
}

- (void)dealloc {
  [pairs release];

  [super dealloc];
}

@end

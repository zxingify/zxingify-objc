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

#import "ZXDimensions.h"

@implementation ZXDimensions

@synthesize minCols;
@synthesize maxCols;
@synthesize minRows;
@synthesize maxRows;

- (id)initWithMinCols:(int)aMinCols maxCols:(int)aMaxCols minRows:(int)aMinRows maxRows:(int)aMaxRows {
  if (self = [super init]) {
    self.minCols = aMinCols;
    self.maxCols = aMaxCols;
    self.minRows = aMinRows;
    self.maxRows = aMaxRows;
  }

  return self;
}

@end

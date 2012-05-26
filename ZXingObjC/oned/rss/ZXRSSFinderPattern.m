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

#import "ZXRSSFinderPattern.h"

@interface ZXRSSFinderPattern ()

@property (nonatomic, assign) int value;
@property (nonatomic, retain) NSArray * startEnd;
@property (nonatomic, retain) NSArray * resultPoints;

@end

@implementation ZXRSSFinderPattern

@synthesize value;
@synthesize startEnd;
@synthesize resultPoints;

- (id)initWithValue:(int)aValue startEnd:(NSArray *)aStartEnd start:(int)aStart end:(int)anEnd rowNumber:(int)aRowNumber {
  if (self = [super init]) {
    self.value = aValue;
    self.startEnd = aStartEnd;
    self.resultPoints = [NSArray arrayWithObjects:
                         [[[ZXResultPoint alloc] initWithX:(float)aStart y:(float)aRowNumber] autorelease],
                         [[[ZXResultPoint alloc] initWithX:(float)anEnd y:(float)aRowNumber] autorelease],
                         nil];
  }

  return self;
}

- (void)dealloc {
  [startEnd release];
  [resultPoints release];

  [super dealloc];
}

@end

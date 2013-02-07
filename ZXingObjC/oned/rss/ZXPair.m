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
#import "ZXPair.h"

@interface ZXPair ()

@property (nonatomic, assign) int count;
@property (nonatomic, retain) ZXRSSFinderPattern *finderPattern;

@end

@implementation ZXPair

@synthesize count;
@synthesize finderPattern;

- (id)initWithValue:(int)aValue checksumPortion:(int)aChecksumPortion finderPattern:(ZXRSSFinderPattern *)aFinderPattern {
  if (self = [super initWithValue:aValue checksumPortion:aChecksumPortion]) {
    self.finderPattern = aFinderPattern;
  }

  return self;
}

- (void)dealloc {
  [finderPattern release];

  [super dealloc];
}


- (void)incrementCount {
  self.count++;
}

@end

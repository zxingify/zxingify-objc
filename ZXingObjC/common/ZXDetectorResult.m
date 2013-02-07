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

#import "ZXBitMatrix.h"
#import "ZXDetectorResult.h"

@interface ZXDetectorResult ()

@property (nonatomic, retain) ZXBitMatrix *bits;
@property (nonatomic, retain) NSArray *points;

@end

@implementation ZXDetectorResult

@synthesize bits;
@synthesize points;

- (id)initWithBits:(ZXBitMatrix *)theBits points:(NSArray *)thePoints {
  if (self = [super init]) {
    self.bits = theBits;
    self.points = thePoints;
  }

  return self;
}

- (void)dealloc {
  [bits release];
  [points release];

  [super dealloc];
}

@end

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

#import "ZXDecodedInformation.h"

@interface ZXDecodedInformation ()

@property (nonatomic, copy) NSString *theNewString;
@property (nonatomic, assign) int remainingValue;
@property (nonatomic, assign) BOOL remaining;

@end

@implementation ZXDecodedInformation

@synthesize remaining;
@synthesize remainingValue;
@synthesize theNewString;

- (id)initWithNewPosition:(int)aNewPosition newString:(NSString *)aNewString {
  if (self = [super initWithNewPosition:aNewPosition]) {
    self.remaining = NO;
    self.remainingValue = 0;
    self.theNewString = aNewString;
  }

  return self;
}

- (id)initWithNewPosition:(int)aNewPosition newString:(NSString *)aNewString remainingValue:(int)aRemainingValue {
  if (self = [super initWithNewPosition:aNewPosition]) {
    self.remaining = YES;
    self.remainingValue = aRemainingValue;
    self.theNewString = aNewString;
  }

  return self;
}

- (void)dealloc {
  [theNewString release];

  [super dealloc];
}

@end

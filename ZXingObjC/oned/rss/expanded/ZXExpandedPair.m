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

#import "ZXExpandedPair.h"
#import "ZXDataCharacter.h"
#import "ZXRSSFinderPattern.h"

@interface ZXExpandedPair ()

@property (nonatomic, retain) ZXDataCharacter * leftChar;
@property (nonatomic, retain) ZXDataCharacter * rightChar;
@property (nonatomic, retain) ZXRSSFinderPattern * finderPattern;
@property (nonatomic, assign) BOOL mayBeLast;

@end

@implementation ZXExpandedPair

@synthesize finderPattern;
@synthesize leftChar;
@synthesize mayBeLast;
@synthesize rightChar;

- (id)initWithLeftChar:(ZXDataCharacter *)aLeftChar rightChar:(ZXDataCharacter *)aRightChar
         finderPattern:(ZXRSSFinderPattern *)aFinderPattern mayBeLast:(BOOL)aMayBeLast {
  if (self = [super init]) {
    self.leftChar = aLeftChar;
    self.rightChar = aRightChar;
    self.finderPattern = aFinderPattern;
    mayBeLast = aMayBeLast;
  }

  return self;
}

- (void)dealloc {
  [leftChar release];
  [rightChar release];
  [finderPattern release];

  [super dealloc];
}

- (BOOL)mustBeLast {
  return self.rightChar == nil;
}

@end

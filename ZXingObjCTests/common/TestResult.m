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

#import "TestResult.h"

@implementation TestResult

@synthesize mustPassCount;
@synthesize tryHarderCount;
@synthesize maxMisreads;
@synthesize maxTryHarderMisreads;
@synthesize rotation;

- (id)initWithMustPassCount:(int)aMustPassCount tryHarderCount:(int)aTryHarderCount maxMisreads:(int)aMaxMisreads
       maxTryHarderMisreads:(int)aMaxTryHarderMisreads rotation:(float)aRotation {
  if (self = [super init]) {
    mustPassCount = aMustPassCount;
    tryHarderCount = aTryHarderCount;
    maxMisreads = aMaxMisreads;
    maxTryHarderMisreads = aMaxTryHarderMisreads;
    rotation = aRotation;
  }

  return self;
}

@end

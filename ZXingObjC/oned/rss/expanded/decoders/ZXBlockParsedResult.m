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

#import "ZXBlockParsedResult.h"
#import "ZXDecodedInformation.h"

@interface ZXBlockParsedResult ()

@property (nonatomic, retain) ZXDecodedInformation *decodedInformation;
@property (nonatomic, assign) BOOL finished;

@end

@implementation ZXBlockParsedResult

@synthesize decodedInformation;
@synthesize finished;

- (id)initWithFinished:(BOOL)isFinished {
  return [self initWithInformation:nil finished:isFinished];
}

- (id)initWithInformation:(ZXDecodedInformation *)information finished:(BOOL)isFinished {
  if (self = [super init]) {
    self.decodedInformation = information;
    self.finished = isFinished;
  }

  return self;
}

- (void)dealloc {
  [decodedInformation release];

  [super dealloc];
}

@end

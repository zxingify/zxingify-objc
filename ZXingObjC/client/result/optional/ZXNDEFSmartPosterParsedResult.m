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

#import "ZXNDEFSmartPosterParsedResult.h"

int const ACTION_UNSPECIFIED = -1;
int const ACTION_DO = 0;
int const ACTION_SAVE = 1;
int const ACTION_OPEN = 2;

@interface ZXNDEFSmartPosterParsedResult ()

@property (nonatomic) int action;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * uri;

@end

@implementation ZXNDEFSmartPosterParsedResult

@synthesize action;
@synthesize title;
@synthesize uri;

- (id)initWithAction:(int)anAction uri:(NSString *)aUri title:(NSString *)aTitle {
  if (self = [super initWithType:kParsedResultTypeNDEFSMartPoster]) {
    self.action = anAction;
    self.uri = aUri;
    self.title = aTitle;
  }

  return self;
}

- (void)dealloc {
  [title release];
  [uri release];

  [super dealloc];
}

- (NSString *)displayResult {
  if (self.title == nil) {
    return self.uri;
  } else {
    return [[self.title stringByAppendingString:@"\n"] stringByAppendingString:self.uri];
  }
}

@end

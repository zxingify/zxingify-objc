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

#import "ZXUPCEANExtensionSupport.h"
#import "ZXUPCEANExtension2Support.h"
#import "ZXUPCEANExtension5Support.h"
#import "ZXUPCEANReader.h"

#define EXTENSION_START_PATTERN_LEN 3
const int EXTENSION_START_PATTERN[EXTENSION_START_PATTERN_LEN] = {1,1,2};

@interface ZXUPCEANExtensionSupport ()

@property (nonatomic, retain) ZXUPCEANExtension2Support *twoSupport;
@property (nonatomic, retain) ZXUPCEANExtension5Support *fiveSupport;

@end

@implementation ZXUPCEANExtensionSupport

@synthesize twoSupport;
@synthesize fiveSupport;

- (id)init {
  if (self = [super init]) {
    self.twoSupport = [[[ZXUPCEANExtension2Support alloc] init] autorelease];
    self.fiveSupport = [[[ZXUPCEANExtension5Support alloc] init] autorelease];
  }

  return self;
}

- (void)dealloc {
  [twoSupport release];
  [fiveSupport release];

  [super dealloc];
}

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row rowOffset:(int)rowOffset error:(NSError **)error {
  NSRange extensionStartRange = [ZXUPCEANReader findGuardPattern:row rowOffset:rowOffset whiteFirst:NO pattern:(int *)EXTENSION_START_PATTERN patternLen:EXTENSION_START_PATTERN_LEN error:error];

  ZXResult *result = [self.fiveSupport decodeRow:rowNumber row:row extensionStartRange:extensionStartRange error:error];
  if (!result) {
    result = [self.twoSupport decodeRow:rowNumber row:row extensionStartRange:extensionStartRange error:error];
  }

  return result;
}

@end

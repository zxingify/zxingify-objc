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

#import "ZXDecodedChar.h"

unichar const FNC1char = '$';

@interface ZXDecodedChar ()

@property (nonatomic, assign) unichar value;

@end

@implementation ZXDecodedChar

@synthesize value;

- (id) initWithNewPosition:(int)aNewPosition value:(unichar)aValue {
  if (self = [super initWithNewPosition:aNewPosition]) {
    self.value = aValue;
  }

  return self;
}

- (BOOL)fnc1 {
  return self.value == FNC1char;
}

@end

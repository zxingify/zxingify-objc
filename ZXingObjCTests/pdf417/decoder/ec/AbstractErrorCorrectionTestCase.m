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

#import "AbstractErrorCorrectionTestCase.h"

@implementation AbstractErrorCorrectionTestCase

- (void)corrupt:(ZXIntArray *)received howMany:(int)howMany {
  ZXBoolArray *corrupted = [[ZXBoolArray alloc] initWithLength:received.length];
  for (int j = 0; j < howMany; j++) {
    int location = arc4random() % received.length;
    if (corrupted.array[location]) {
      j--;
    } else {
      corrupted.array[location] = YES;
      received.array[location] = (int32_t)(arc4random() % 929);
    }
  }
}

/*
- (ZXIntArray *)erase:(ZXIntArray *)received howMany:(int)howMany {
  ZXBoolArray *erased = [[ZXBoolArray alloc] initWithLength:received.length];
  ZXIntArray *erasures = [[ZXIntArray alloc] initWithLength:howMany];
  int erasureOffset = 0;
  for (int j = 0; j < howMany; j++) {
    int location = arc4random() % received.length;
    if (erased.array[location]) {
      j--;
    } else {
      erased.array[location] = YES;
      received.array[location] = 0;
      erasures.array[erasureOffset++] = location;
    }
  }
  return erasures;
}
*/

@end

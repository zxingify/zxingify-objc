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
#import "ZXGenericGF.h"
#import "ZXReedSolomonEncoder.h"

@implementation AbstractErrorCorrectionTestCase

- (void)corrupt:(NSMutableArray *)received howMany:(int)howMany {
  BOOL corrupted[received.count];
  for (int i = 0; i < received.count; i++) {
    corrupted[i] = NO;
  }

  for (int j = 0; j < howMany; j++) {
    int location = arc4random() % received.count;
    if (corrupted[location]) {
      j--;
    } else {
      corrupted[location] = YES;
      [received replaceObjectAtIndex:location withObject:[NSNumber numberWithInt:arc4random() % 929]];
    }
  }
}

- (NSArray *)erase:(NSMutableArray *)received howMany:(int)howMany {
  BOOL erased[received.count];
  for (int i = 0; i < received.count; i++) {
    erased[i] = NO;
  }

  NSMutableArray *erasures = [NSMutableArray arrayWithCapacity:howMany];
  for (int j = 0; j < howMany; j++) {
    int location = arc4random() % received.count;
    if (erased[location]) {
      j--;
    } else {
      erased[location] = YES;
      [received replaceObjectAtIndex:location withObject:[NSNumber numberWithInt:0]];
      [erasures addObject:[NSNumber numberWithInt:location]];
    }
  }
  return erasures;
}

@end

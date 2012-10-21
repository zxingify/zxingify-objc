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

#import "ZXModulusGF.h"
#import "ZXModulusPoly.h"
#import "ZXPDF417ECErrorCorrection.h"

@interface ZXPDF417ECErrorCorrection ()

@property (nonatomic, retain) ZXModulusGF* field;

@end

@implementation ZXPDF417ECErrorCorrection

@synthesize field;

- (id)init {
  if (self = [super init]) {
    self.field = [ZXModulusGF PDF417_GF];
  }

  return self;
}

- (void)dealloc {
  [field release];

  [super dealloc];
}

- (BOOL)decode:(NSArray *)received numECCodewords:(int)numECCodewords {
  int coefficients[received.count];
  for (int i = 0; i < received.count; i++) {
    coefficients[i] = [[received objectAtIndex:i] intValue];
  }

  ZXModulusPoly *poly = [[[ZXModulusPoly alloc] initWithField:self.field coefficients:coefficients coefficientsLen:received.count] autorelease];
  int *syndromeCoefficients = (int*)malloc(numECCodewords * sizeof(int));
  memset(syndromeCoefficients, 0, numECCodewords * sizeof(int));
  BOOL noError = YES;
  for (int i = 0; i < numECCodewords; i++) {
    int eval = [poly evaluateAt:[self.field exp:i + 1]];
    syndromeCoefficients[numECCodewords - 1 - i] = eval;
    if (eval != 0) {
      noError = NO;
    }
  }

  return noError;
  // TODO actually correct errors!
}

@end

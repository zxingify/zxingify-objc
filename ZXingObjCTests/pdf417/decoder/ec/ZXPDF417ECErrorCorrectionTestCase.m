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

#import "ZXPDF417ECErrorCorrectionTestCase.h"

@interface ZXPDF417ECErrorCorrectionTestCase ()

@property (nonatomic, strong, readonly) ZXPDF417ECErrorCorrection *ec;

@end

@implementation ZXPDF417ECErrorCorrectionTestCase

static ZXIntArray *PDF417_TEST = nil;
static ZXIntArray *PDF417_TEST_WITH_EC = nil;
static int ECC_BYTES;
// Example is EC level 1 (s=1). The number of erasures (l) and substitutions (f) must obey:
// l + 2f <= 2^(s+1) - 3
const int EC_LEVEL = 5;
const int ERROR_LIMIT = (1 << (EC_LEVEL + 1)) - 3;
const int MAX_ERRORS = ERROR_LIMIT / 2;

+ (void)initialize {
  /** See ISO 15438, Annex Q */

  PDF417_TEST = [[ZXIntArray alloc] initWithInts:
      48, 901, 56, 141, 627, 856, 330, 69, 244, 900, 852, 169, 843, 895, 852, 895, 913, 154, 845, 778, 387, 89, 869,
      901, 219, 474, 543, 650, 169, 201, 9, 160, 35, 70, 900, 900, 900, 900, 900, 900, 900, 900, 900, 900, 900, 900,
      900, 900, -1];

  PDF417_TEST_WITH_EC = [[ZXIntArray alloc] initWithInts:
      48, 901, 56, 141, 627, 856, 330, 69, 244, 900, 852, 169, 843, 895, 852, 895, 913, 154, 845, 778, 387, 89, 869,
      901, 219, 474, 543, 650, 169, 201, 9, 160, 35, 70, 900, 900, 900, 900, 900, 900, 900, 900, 900, 900, 900, 900,
      900, 900, 769, 843, 591, 910, 605, 206, 706, 917, 371, 469, 79, 718, 47, 777, 249, 262, 193, 620, 597, 477, 450,
      806, 908, 309, 153, 871, 686, 838, 185, 674, 68, 679, 691, 794, 497, 479, 234, 250, 496, 43, 347, 582, 882, 536,
      322, 317, 273, 194, 917, 237, 420, 859, 340, 115, 222, 808, 866, 836, 417, 121, 833, 459, 64, 159, -1];

  ECC_BYTES = PDF417_TEST_WITH_EC.length - PDF417_TEST.length;
}

- (id)initWithInvocation:(NSInvocation *)invocation {
  if (self = [super initWithInvocation:invocation]) {
    _ec = [[ZXPDF417ECErrorCorrection alloc] init];
  }

  return self;
}

- (void)testNoError {
  ZXIntArray *received = [PDF417_TEST_WITH_EC copy];
  // no errors
  [self checkDecode:received];
}

- (void)testOneError {
  for (int i = 0; i < PDF417_TEST_WITH_EC.length; i++) {
    ZXIntArray *received = [PDF417_TEST_WITH_EC copy];
    received.array[i] = (int32_t)(arc4random() % 256);
    [self checkDecode:received];
  }
}

- (void)testMaxErrors {
  for (int testIterations = 0; testIterations < 100; testIterations++) { // # iterations is kind of arbitrary
    ZXIntArray *received = [PDF417_TEST_WITH_EC copy];
    [self corrupt:received howMany:MAX_ERRORS];
    [self checkDecode:received];
  }
}

- (void)testTooManyErrors {
  ZXIntArray *received = [PDF417_TEST_WITH_EC copy];
  [self corrupt:received howMany:MAX_ERRORS + 3]; // +3 since the algo can actually correct 2 more than it should here

  if ([self checkDecode:received]) {
    XCTFail(@"Should not have decoded");
  }
}

- (BOOL)checkDecode:(ZXIntArray *)received {
  return [self checkDecode:received erasures:[[ZXIntArray alloc] initWithLength:0]];
}

- (BOOL)checkDecode:(ZXIntArray *)received erasures:(ZXIntArray *)erasures {
  if (![self.ec decode:received numECCodewords:ECC_BYTES erasures:erasures]) {
    return NO;
  }

  for (int i = 0; i < PDF417_TEST.length; i++) {
    XCTAssertEqual(received.array[i], PDF417_TEST.array[i]);
  }
  return YES;
}

@end

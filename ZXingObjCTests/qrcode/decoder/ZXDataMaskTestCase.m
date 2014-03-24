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

#import "ZXDataMaskTestCase.h"

typedef BOOL (^MaskCondition)(int i, int j);

@implementation ZXDataMaskTestCase

- (void)testMask0 {
  [self runTestMaskAcrossDimensions:0 condition:^BOOL(int i, int j) {
    return (i + j) % 2 == 0;
  }];
}

- (void)testMask1 {
  [self runTestMaskAcrossDimensions:1 condition:^BOOL(int i, int j) {
    return i % 2 == 0;
  }];
}

- (void)testMask2 {
  [self runTestMaskAcrossDimensions:2 condition:^BOOL(int i, int j) {
    return j % 3 == 0;
  }];
}

- (void)testMask3 {
  [self runTestMaskAcrossDimensions:3 condition:^BOOL(int i, int j) {
    return (i + j) % 3 == 0;
  }];
}

- (void)testMask4 {
  [self runTestMaskAcrossDimensions:4 condition:^BOOL(int i, int j) {
    return (i / 2 + j / 3) % 2 == 0;
  }];
}

- (void)testMask5 {
  [self runTestMaskAcrossDimensions:5 condition:^BOOL(int i, int j) {
    return (i * j) % 2 + (i * j) % 3 == 0;
  }];
}

- (void)testMask6 {
  [self runTestMaskAcrossDimensions:6 condition:^BOOL(int i, int j) {
    return ((i * j) % 2 + (i * j) % 3) % 2 == 0;
  }];
}

- (void)testMask7 {
  [self runTestMaskAcrossDimensions:7 condition:^BOOL(int i, int j) {
    return ((i + j) % 2 + (i * j) % 3) % 2 == 0;
  }];
}

- (void)runTestMaskAcrossDimensions:(int)reference condition:(MaskCondition)condition {
  ZXDataMask *mask = [ZXDataMask forReference:reference];
  for (int version = 1; version <= 40; version++) {
    int dimension = 17 + 4 * version;
    [self runTestMask:mask dimension:dimension condition:condition];
  }
}

- (void)runTestMask:(ZXDataMask *)mask dimension:(int)dimension condition:(MaskCondition)condition {
  ZXBitMatrix *bits = [[ZXBitMatrix alloc] initWithDimension:dimension];
  [mask unmaskBitMatrix:bits dimension:dimension];
  for (int i = 0; i < dimension; i++) {
    for (int j = 0; j < dimension; j++) {
      XCTAssertEqual(condition(i, j), [bits getX:j y:i], @"(%d,%d)", i, j);
    }
  }
}

@end

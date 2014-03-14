/*
 * Copyright 2014 ZXing authors
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

#import "ZXAztecDetectorTest.h"

unsigned int ZXAztecDetectorTest_RANDOM_SEED = 16807;

@implementation ZXAztecDetectorTest

- (void)testErrorInParameterLocatorZeroZero {
  // Layers=1, CodeWords=1.  So the parameter info and its Reed-Solomon info
  // will be completely zero!
  [self testErrorInParameterLocator:@"X"];
}

- (void)testErrorInParameterLocatorCompact {
  [self testErrorInParameterLocator:@"This is an example Aztec symbol for Wikipedia."];
}

- (void)testErrorInParameterLocatorNotCompact {
  NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYabcdefghijklmnopqrstuvwxyz";
  [self testErrorInParameterLocator:[NSString stringWithFormat:@"%@%@%@", alphabet, alphabet, alphabet]];
}

// Test that we can tolerate errors in the parameter locator bits
- (void)testErrorInParameterLocator:(NSString *)data {
  ZXAztecCode *aztec = [ZXAztecEncoder encode:[[data dataUsingEncoding:NSISOLatin1StringEncoding] bytes] len:[data lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding]];
  int layers = aztec.layers;
  BOOL compact = aztec.isCompact;
  NSMutableArray *orientationPoints = [self orientationPoints:aztec];
  srand(ZXAztecDetectorTest_RANDOM_SEED);
  for (ZXBitMatrix *matrix in [self rotations:aztec.matrix]) {
    // Each time through this loop, we reshuffle the corners, to get a different set of errors
    [self shuffle:orientationPoints];
    for (int errors = 1; errors <= 3; errors++) {
      // Add another error to one of the parameter locator bits
      [matrix flipX:[(ZXAztecPoint *)orientationPoints[errors] x] y:[(ZXAztecPoint *)orientationPoints[errors] y]];

      // The detector can't yet deal with bitmaps in which each square is only 1x1 pixel.
      // We zoom it larger.
      NSError *error;
      ZXAztecDetectorResult *r = [[[ZXAztecDetector alloc] initWithImage:[self makeLarger:matrix factor:3]] detectWithError:&error];
      if (errors < 3) {
        XCTAssertNotNil(r, @"");
        XCTAssertEqual(layers, r.nbLayers, @"");
        XCTAssertEqual(compact, r.isCompact, @"");
      } else if (!error) {
        XCTFail(@"Should not succeed with more than two errors");
      } else {
        XCTAssertEqual(errors, 3, @"Should only fail with three errors");
      }
    }
  }
}

// Zooms a bit matrix so that each bit is factor x factor
- (ZXBitMatrix *)makeLarger:(ZXBitMatrix *)input factor:(int)factor {
  int width = input.width;
  ZXBitMatrix *output = [[ZXBitMatrix alloc] initWithDimension:width * factor];
  for (int inputY = 0; inputY < width; inputY++) {
    for (int inputX = 0; inputX < width; inputX++) {
      if ([input getX:inputX y:inputY]) {
        [output setRegionAtLeft:inputX * factor top:inputY * factor width:factor height:factor];
      }
    }
  }
  return output;
}

// Returns a list of the four rotations of the BitMatrix.  The identity rotation is
// explicitly a copy, so that it can be modified without affecting the original matrix.
- (NSArray *)rotations:(ZXBitMatrix *)input {
  int width = input.width;
  ZXBitMatrix *matrix0 = [[ZXBitMatrix alloc] initWithDimension:width];
  ZXBitMatrix *matrix90 = [[ZXBitMatrix alloc] initWithDimension:width];
  ZXBitMatrix *matrix180 = [[ZXBitMatrix alloc] initWithDimension:width];
  ZXBitMatrix *matrix270 = [[ZXBitMatrix alloc] initWithDimension:width];
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < width; y++) {
      if ([input getX:x y:y]) {
        [matrix0 setX:x y:y];
        [matrix90 setX:y y:width - x - 1];
        [matrix180 setX:width - x - 1 y:width - y - 1];
        [matrix270 setX:width - y - 1 y:x];
      }
    }
  }
  return @[matrix0, matrix90, matrix180, matrix270];
}

- (NSMutableArray *)orientationPoints:(ZXAztecCode *)code {
  int center = code.matrix.width / 2;
  int offset = code.isCompact ? 5 : 7;
  NSMutableArray *result = [NSMutableArray array];
  for (int xSign = -1; xSign <= 1; xSign += 2) {
    for (int ySign = -1; ySign <= 1; ySign += 2) {
      [result addObject:[[ZXAztecPoint alloc] initWithX:center + xSign * offset y:center + ySign * offset]];
      [result addObject:[[ZXAztecPoint alloc] initWithX:center + xSign * (offset - 1) y:center + ySign * offset]];
      [result addObject:[[ZXAztecPoint alloc] initWithX:center + xSign * offset y:center + ySign * (offset - 1)]];
    }
  }
  return result;
}

- (void)shuffle:(NSMutableArray *)array {
  NSUInteger count = [array count];
  for (NSUInteger i = 0; i < count; ++i) {
    // Select a random element between i and end of array to swap with.
    NSInteger nElements = count - i;
    NSInteger n = rand() % nElements + i;
    [array exchangeObjectAtIndex:i withObjectAtIndex:n];
  }
}

@end

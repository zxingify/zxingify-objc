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
  ZXByteArray *bytes = [[ZXByteArray alloc] initWithLength:(unsigned int)[data lengthOfBytesUsingEncoding:NSISOLatin1StringEncoding]];
  memcpy(bytes.array, [[data dataUsingEncoding:NSISOLatin1StringEncoding] bytes], bytes.length * sizeof(int8_t));
  ZXAztecCode *aztec = [ZXAztecEncoder encode:bytes minECCPercent:25 userSpecifiedLayers:ZX_AZTEC_DEFAULT_LAYERS];
  int layers = aztec.layers;
  BOOL compact = aztec.isCompact;
  NSMutableArray *orientationPoints = [self orientationPoints:aztec];
  srand(ZXAztecDetectorTest_RANDOM_SEED);
  for (NSNumber *isMirrorNum in @[@NO, @YES]) {
    BOOL isMirror = [isMirrorNum boolValue];
    for (ZXBitMatrix *matrix in [self rotations:aztec.matrix]) {
      // Systematically try every possible 1- and 2-bit error.
      for (int error1 = 0; error1 < [orientationPoints count]; error1++) {
        for (int error2 = error1; error2 < orientationPoints.count; error2++) {
          ZXBitMatrix *copy = isMirror ? [self transpose:matrix] : [self clone:matrix];
          [copy flipX:[(ZXAztecPoint *)orientationPoints[error1] x] y:[(ZXAztecPoint *)orientationPoints[error1] y]];
          if (error2 > error1) {
            // if error2 == error1, we only test a single error
            [copy flipX:[(ZXAztecPoint *)orientationPoints[error2] x] y:[(ZXAztecPoint *)orientationPoints[error2] y]];
          }
          // The detector doesn't seem to work when matrix bits are only 1x1.  So magnify.
          ZXAztecDetectorResult *r = [[[ZXAztecDetector alloc] initWithImage:[self makeLarger:copy factor:3]] detectWithMirror:isMirror error:nil];
          XCTAssertNotNil(r, @"");
          XCTAssertEqual(layers, r.nbLayers, @"");
          XCTAssertEqual(compact, r.isCompact, @"");
          ZXDecoderResult *res = [[[ZXAztecDecoder alloc] init] decode:r error:nil];
          XCTAssertEqualObjects(res.text, data, @"%@ should equal %@", res.text, data);
        }
      }
      // Try a few random three-bit errors;
      for (int i = 0; i < 5; i++) {
        ZXBitMatrix *copy = [self clone:matrix];
        NSMutableOrderedSet *errors = [[NSMutableOrderedSet alloc] init];
        while ([errors count] < 3) {
          // Quick and dirty way of getting three distinct integers between 1 and n.
          [errors addObject:@(rand() % [orientationPoints count])];
        }
        for (NSNumber *errorNum in errors) {
          [copy flipX:[(ZXAztecPoint *)orientationPoints[[errorNum intValue]] x] y:[(ZXAztecPoint *)orientationPoints[[errorNum intValue]] y]];
        }
        if ([[[ZXAztecDetector alloc] initWithImage:[self makeLarger:copy factor:3]] detectWithMirror:NO error:nil]) {
          XCTFail(@"Should not reach here");
        }
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

// Returns a list of the four rotations of the ZXBitMatrix.
- (NSArray *)rotations:(ZXBitMatrix *)input {
  ZXBitMatrix *matrix0 = input;
  ZXBitMatrix *matrix90 = [self rotateRight:input];
  ZXBitMatrix *matrix180 = [self rotateRight:matrix90];
  ZXBitMatrix *matrix270 = [self rotateRight:matrix180];
  return @[matrix0, matrix90, matrix180, matrix270];
}

// Rotates a square BitMatrix to the right by 90 degrees
- (ZXBitMatrix *)rotateRight:(ZXBitMatrix *)input {
  int width = input.width;
  ZXBitMatrix *result = [[ZXBitMatrix alloc] initWithDimension:width];
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < width; y++) {
      if ([input getX:x y:y]) {
        [result setX:y y:width - x - 1];
      }
    }
  }
  return result;
}

// Returns the transpose of a bit matrix, which is equivalent to rotating the
// matrix to the right, and then flipping it left-to-right
- (ZXBitMatrix *)transpose:(ZXBitMatrix *)input {
  int width = input.width;
  ZXBitMatrix *result = [[ZXBitMatrix alloc] initWithDimension:width];
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < width; y++) {
      if ([input getX:x y:y]) {
        [result setX:y y:x];
      }
    }
  }
  return result;
}

- (ZXBitMatrix *)clone:(ZXBitMatrix *)input {
  int width = input.width;
  ZXBitMatrix *result = [[ZXBitMatrix alloc] initWithDimension:width];
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < width; y++) {
      if ([input getX:x y:y]) {
        [result setX:x y:y];
      }
    }
  }
  return result;
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

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

#import "ZXAbstractNegativeBlackBoxTestCase.h"

@interface NegativeTestResult : NSObject

@property (nonatomic, assign) int falsePositivesAllowed;
@property (nonatomic, assign) float rotation;

@end

@implementation NegativeTestResult

- (id)initWithFalsePositivesAllowed:(int)falsePositivesAllowed rotation:(float)rotation {
  if (self = [super init]) {
    _falsePositivesAllowed = falsePositivesAllowed;
    _rotation = rotation;
  }

  return self;
}

@end

@implementation ZXAbstractNegativeBlackBoxTestCase

// Use the multiformat reader to evaluate all decoders in the system.
- (id)initWithInvocation:(NSInvocation *)invocation testBasePathSuffix:(NSString *)testBasePathSuffix {
  if (self = [super initWithInvocation:invocation testBasePathSuffix:testBasePathSuffix barcodeReader:[[ZXMultiFormatReader alloc] init] expectedFormat:0]) {
    self.testResults = [NSMutableArray array];
  }

  return self;
}

- (void)addTest:(int)falsePositivesAllowed rotation:(float)rotation {
  [self.testResults addObject:[[NegativeTestResult alloc] initWithFalsePositivesAllowed:falsePositivesAllowed rotation:rotation]];
}

- (NSString *)pathInBundle:(NSURL *)file {
  NSInteger startOfResources = [[file path] rangeOfString:@"Resources"].location;
  if (startOfResources == NSNotFound) {
    return [file path];
  } else {
    return [[file path] substringFromIndex:startOfResources];
  }
}

- (void)runTests {
  if (self.testResults.count == 0) {
    XCTFail(@"No test results");
  }

  NSArray *imageFiles = [self imageFiles];

  ZXIntArray *falsePositives = [[ZXIntArray alloc] initWithLength:(unsigned int)[self.testResults count]];

  for (NSURL *testImage in imageFiles) {
    NSLog(@"Starting %@", [self pathInBundle:testImage]);

    ZXImage *image = [[ZXImage alloc] initWithURL:testImage];
    for (int x = 0; x < self.testResults.count; x++) {
      NegativeTestResult *testResult = self.testResults[x];
      if (![self checkForFalsePositives:image rotationInDegrees:testResult.rotation]) {
        falsePositives.array[x]++;
      }
    }
  }

  int totalFalsePositives = 0;
  int totalAllowed = 0;

  for (int x = 0; x < self.testResults.count; x++) {
    NegativeTestResult *testResult = self.testResults[x];
    totalFalsePositives += falsePositives.array[x];
    totalAllowed += testResult.falsePositivesAllowed;
  }

  if (totalFalsePositives < totalAllowed) {
    NSLog(@"  +++ Test too lax by %d images", totalAllowed - totalFalsePositives);
  } else if (totalFalsePositives > totalAllowed) {
    NSLog(@"  --- Test failed by %d images", totalFalsePositives - totalAllowed);
  }

  for (int x = 0; x < self.testResults.count; x++) {
    NegativeTestResult *testResult = self.testResults[x];
    NSLog(@"Rotation %d degrees: %d of %d images were false positives (%d allowed)",
          (int)testResult.rotation, falsePositives.array[x], (int)imageFiles.count,
          testResult.falsePositivesAllowed);
    XCTAssertTrue(falsePositives.array[x] <= testResult.falsePositivesAllowed,
                 @"Rotation %f degrees: Too many false positives found", testResult.rotation);
  }
}

/**
 * Make sure ZXing does NOT find a barcode in the image.
 */
- (BOOL)checkForFalsePositives:(ZXImage *)image rotationInDegrees:(CGFloat)rotationInDegrees {
  ZXImage *rotatedImage = [self rotateImage:image degrees:rotationInDegrees];
  ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:rotatedImage.cgimage];
  ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXHybridBinarizer alloc] initWithSource:source]];
  NSError *error = nil;
  ZXResult *result = [self.barcodeReader decode:bitmap error:&error];
  if (result) {
    NSLog(@"Found false positive: '%@' with format '%@' (rotation: %d)",
          result.text, [ZXAbstractBlackBoxTestCase barcodeFormatAsString:result.barcodeFormat], (int) rotationInDegrees);
    return NO;
  }

  // Try "try harder" getMode
  ZXDecodeHints *hints = [ZXDecodeHints hints];
  hints.tryHarder = YES;
  result = [self.barcodeReader decode:bitmap hints:hints error:&error];
  if (result) {
    NSLog(@"Try harder found false positive: '%@' with format '%@' (rotation: %d)",
          result.text, [ZXAbstractBlackBoxTestCase barcodeFormatAsString:result.barcodeFormat], (int) rotationInDegrees);
    return NO;
  }
  return YES;
}

@end

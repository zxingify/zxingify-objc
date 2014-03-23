/*
 * Copyright 2013 ZXing authors
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

#import "PDF417BlackBox4TestCase.h"
#import "TestResult.h"

@implementation PDF417BlackBox4TestCase

- (id)initWithInvocation:(NSInvocation *)invocation {
  self = [super initWithInvocation:invocation
                testBasePathSuffix:@"Resources/blackbox/pdf417-4"
                     barcodeReader:[[ZXPDF417Reader alloc] init]
                    expectedFormat:kBarcodeFormatPDF417];

  if (self) {
    [self.testResults addObject:[[TestResult alloc] initWithMustPassCount:2 tryHarderCount:2 maxMisreads:0 maxTryHarderMisreads:0 rotation:0.0f]];
  }

  return self;
}

- (void)testBlackBox {
  [self testPDF417BlackBoxCountingResults:YES];
}

- (void)testPDF417BlackBoxCountingResults:(BOOL)assertOnFailure {
  XCTAssertFalse([self.testResults count] == 0, @"Expected testResults to be non-empty");

  NSDictionary *imageFiles = [self imageFileLists];
  int testCount = (int)[self.testResults count];

  ZXIntArray *passedCounts = [[ZXIntArray alloc] initWithLength:testCount];
  ZXIntArray *misreadCounts = [[ZXIntArray alloc] initWithLength:testCount];
  ZXIntArray *tryHarderCounts = [[ZXIntArray alloc] initWithLength:testCount];
  ZXIntArray *tryHarderMisreadCounts = [[ZXIntArray alloc] initWithLength:testCount];

  for (NSString *fileBaseName in [imageFiles allKeys]) {
    NSLog(@"Starting Image Group %@", fileBaseName);

    NSString *expectedText;
    NSString *expectedTextFile = [[NSBundle bundleForClass:[self class]] pathForResource:fileBaseName ofType:@"txt" inDirectory:self.testBase];
    if (expectedTextFile) {
      expectedText = [self readFileAsString:expectedTextFile encoding:NSUTF8StringEncoding];
    } else {
      NSString *expectedTextFile = [[NSBundle bundleForClass:[self class]] pathForResource:fileBaseName ofType:@"bin" inDirectory:self.testBase];
      XCTAssertNotNil(expectedTextFile, @"Expected text does not exist");
      expectedText = [self readFileAsString:expectedTextFile encoding:NSISOLatin1StringEncoding];
    }

    for (int x = 0; x < testCount; x++) {
      NSMutableArray *results = [NSMutableArray array];
      for (NSURL *imageFile in imageFiles[fileBaseName]) {
        ZXImage *image = [[ZXImage alloc] initWithURL:imageFile];
        float rotation = [(TestResult *)self.testResults[x] rotation];
        ZXImage *rotatedImage = [self rotateImage:image degrees:rotation];
        ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:rotatedImage.cgimage];
        ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXHybridBinarizer alloc] initWithSource:source]];

        NSArray *imageResults = [self decode:bitmap tryHarder:NO];
        if (!imageResults) {
          continue;
        }

        [results addObjectsFromArray:imageResults];
      }
      [results sortUsingComparator:^NSComparisonResult(ZXResult *arg0, ZXResult *arg1) {
        ZXPDF417ResultMetadata *resultMetadata = [self meta:arg0];
        ZXPDF417ResultMetadata *otherResultMetadata = [self meta:arg1];
        return resultMetadata.segmentIndex - otherResultMetadata.segmentIndex;
      }];
      NSMutableString *resultText = [NSMutableString string];
      NSString *fileId;
      for (ZXResult *result in results) {
        ZXPDF417ResultMetadata *resultMetadata = [self meta:result];
        XCTAssertNotNil(resultMetadata, @"resultMetadata");
        if (!fileId) {
          fileId = resultMetadata.fileId;
        }
        XCTAssertEqualObjects(resultMetadata.fileId, fileId, @"FileId");
        [resultText appendString:result.text];
      }
      XCTAssertEqualObjects(resultText, expectedText, @"ExpectedText");
      passedCounts.array[x]++;
      tryHarderCounts.array[x]++;
    }
  }

  // Print the results of all tests first
  int totalFound = 0;
  int totalMustPass = 0;
  int totalMisread = 0;
  int totalMaxMisread = 0;

  int numberOfTests = (int)[imageFiles count];
  for (int x = 0; x < [self.testResults count]; x++) {
    TestResult *testResult = self.testResults[x];
    NSLog(@"Rotation %d degrees:", (int) testResult.rotation);
    NSLog(@" %d of %d images passed (%d required)", passedCounts.array[x], numberOfTests, testResult.mustPassCount);
    int failed = numberOfTests - passedCounts.array[x];
    NSLog(@" %d failed due to misreads, %d not detected", misreadCounts.array[x], failed - misreadCounts.array[x]);
    NSLog(@" %d of %d images passed with try harder (%d required)", tryHarderCounts.array[x], numberOfTests, testResult.tryHarderCount);
    failed = numberOfTests - tryHarderCounts.array[x];
    NSLog(@" %d failed due to misreads, %d not detected", tryHarderMisreadCounts.array[x], failed - tryHarderMisreadCounts.array[x]);
    totalFound += passedCounts.array[x] + tryHarderCounts.array[x];
    totalMustPass += testResult.mustPassCount + testResult.tryHarderCount;
    totalMisread += misreadCounts.array[x] + tryHarderMisreadCounts.array[x];
    totalMaxMisread += testResult.maxMisreads + testResult.maxTryHarderMisreads;
  }

  int totalTests = numberOfTests * testCount * 2;
  NSLog(@"Decoded %d images out of %d (%d%%, %d required)", totalFound, totalTests, totalFound *
        100 / totalTests, totalMustPass);
  if (totalFound > totalMustPass) {
    NSLog(@"+++ Test too lax by %d images", totalFound - totalMustPass);
  } else if (totalFound < totalMustPass) {
    NSLog(@"--- Test failed by %d images", totalMustPass - totalFound);
  }

  if (totalMisread < totalMaxMisread) {
    NSLog(@"+++ Test expects too many misreads by %d images", totalMaxMisread - totalMisread);
  } else if (totalMisread > totalMaxMisread) {
    NSLog(@"--- Test had too many misreads by %d images", totalMisread - totalMaxMisread);
  }

  // Then run through again and assert if any failed
  if (assertOnFailure) {
    for (int x = 0; x < testCount; x++) {
      TestResult *testResult = self.testResults[x];
      NSString *label = [NSString stringWithFormat:@"Rotation %f degrees: Too many images failed", testResult.rotation];
      XCTAssertTrue(passedCounts.array[x] >= testResult.mustPassCount, @"%@", label);
      XCTAssertTrue(tryHarderCounts.array[x] >= testResult.tryHarderCount, @"Try harder, %@", label);
      label = [NSString stringWithFormat:@"Rotation %f degrees: Too many images misread", testResult.rotation];
      XCTAssertTrue(misreadCounts.array[x] <= testResult.maxMisreads, @"%@", label);
      XCTAssertTrue(tryHarderMisreadCounts.array[x] <= testResult.maxTryHarderMisreads, @"Try harder, %@", label);
    }
  }
}

- (ZXPDF417ResultMetadata *)meta:(ZXResult *)result {
  return result.resultMetadata == nil ? nil : (ZXPDF417ResultMetadata *)result.resultMetadata[@(kResultMetadataTypePDF417ExtraMetadata)];
}

- (NSArray *)decode:(ZXBinaryBitmap *)source tryHarder:(BOOL)tryHarder {
  ZXDecodeHints *hints = [ZXDecodeHints hints];
  hints.tryHarder = tryHarder;

  return [(ZXPDF417Reader *)self.barcodeReader decodeMultiple:source hints:hints error:nil];
}

- (NSDictionary *)imageFileLists {
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  for (NSURL *file in [self imageFiles]) {
    NSString *testImageFileName = [[[file path] componentsSeparatedByString:@"/"] lastObject];
    NSString *fileBaseName = [testImageFileName substringToIndex:[testImageFileName rangeOfString:@"-"].location];
    NSMutableArray *files = result[fileBaseName];
    if (!files) {
      files = [NSMutableArray array];
      result[fileBaseName] = files;
    }
    [files addObject:file];
  }
  return result;
}

@end

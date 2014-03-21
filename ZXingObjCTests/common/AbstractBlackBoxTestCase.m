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

#import "AbstractBlackBoxTestCase.h"
#import "TestResult.h"

@implementation AbstractBlackBoxTestCase

- (id)initWithInvocation:(NSInvocation *)invocation testBasePathSuffix:(NSString *)testBasePathSuffix barcodeReader:(id<ZXReader>)barcodeReader expectedFormat:(ZXBarcodeFormat)expectedFormat {
  if (self = [super initWithInvocation:invocation]) {
    _testBase = testBasePathSuffix;
    _barcodeReader = barcodeReader;
    _expectedFormat = expectedFormat;
    _testResults = [NSMutableArray array];
  }

  return self;
}

- (void)addTest:(int)mustPassCount tryHarderCount:(int)tryHarderCount rotation:(float)rotation {
  [self addTest:mustPassCount tryHarderCount:tryHarderCount maxMisreads:0 maxTryHarderMisreads:0 rotation:rotation];
}

/**
 * Adds a new test for the current directory of images.
 */
- (void)addTest:(int)mustPassCount tryHarderCount:(int)tryHarderCount maxMisreads:(int)maxMisreads maxTryHarderMisreads:(int)maxTryHarderMisreads rotation:(float)rotation {
  [self.testResults addObject:[[TestResult alloc] initWithMustPassCount:mustPassCount tryHarderCount:tryHarderCount maxMisreads:maxMisreads maxTryHarderMisreads:maxTryHarderMisreads rotation:rotation]];
}

- (NSArray *)imageFiles {
  NSMutableArray *imageFiles = [NSMutableArray array];
  for (NSString *file in [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:nil inDirectory:self.testBase]) {
    if ([[[file pathExtension] lowercaseString] isEqualToString:@"jpg"] ||
        [[[file pathExtension] lowercaseString] isEqualToString:@"jpeg"] ||
        [[[file pathExtension] lowercaseString] isEqualToString:@"gif"] ||
        [[[file pathExtension] lowercaseString] isEqualToString:@"png"]) {
      [imageFiles addObject:[NSURL fileURLWithPath:file]];
    }
  }

  return imageFiles;
}

- (void)runTests {
  [self testBlackBoxCountingResults:YES];
}

+ (NSString *)barcodeFormatAsString:(ZXBarcodeFormat)format {
  switch (format) {
    case kBarcodeFormatAztec:
      return @"Aztec";
      break;
    case kBarcodeFormatCodabar:
      return @"CODABAR";
      break;
    case kBarcodeFormatCode39:
      return @"Code 39";
      break;
    case kBarcodeFormatCode93:
      return @"Code 93";
      break;
    case kBarcodeFormatCode128:
      return @"Code 128";
      break;
    case kBarcodeFormatDataMatrix:
      return @"Data Matrix";
      break;
    case kBarcodeFormatEan8:
      return @"EAN-8";
      break;
    case kBarcodeFormatEan13:
      return @"EAN-13";
      break;
    case kBarcodeFormatITF:
      return @"ITF";
      break;
    case kBarcodeFormatMaxiCode:
      return @"MaxiCode";
      break;
    case kBarcodeFormatPDF417:
      return @"PDF417";
      break;
    case kBarcodeFormatQRCode:
      return @"QR Code";
      break;
    case kBarcodeFormatRSS14:
      return @"RSS 14";
      break;
    case kBarcodeFormatRSSExpanded:
      return @"RSS EXPANDED";
      break;
    case kBarcodeFormatUPCA:
      return @"UPC-A";
      break;
    case kBarcodeFormatUPCE:
      return @"UPC-E";
      break;
    case kBarcodeFormatUPCEANExtension:
      return @"UPC/EAN extension";
      break;
  }

  return nil;
}

- (NSString *)pathInBundle:(NSURL *)file {
  NSInteger startOfResources = [[file path] rangeOfString:@"Resources"].location;
  if (startOfResources == NSNotFound) {
    return [file path];
  } else {
    return [[file path] substringFromIndex:startOfResources];
  }
}

- (void)testBlackBoxCountingResults:(BOOL)assertOnFailure {
  if (self.testResults.count == 0) {
    XCTFail(@"No test results");
  }

  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *imageFiles = [self imageFiles];
  int testCount = (int)[self.testResults count];

  ZXIntArray *passedCounts = [[ZXIntArray alloc] initWithLength:testCount];
  ZXIntArray *misreadCounts = [[ZXIntArray alloc] initWithLength:testCount];
  ZXIntArray *tryHarderCounts = [[ZXIntArray alloc] initWithLength:testCount];
  ZXIntArray *tryHarderMisreadCounts = [[ZXIntArray alloc] initWithLength:testCount];

  for (NSURL *testImage in imageFiles) {
    NSLog(@"Starting %@", [self pathInBundle:testImage]);

    ZXImage *image = [[ZXImage alloc] initWithURL:testImage];

    NSString *testImageFileName = [[[testImage path] componentsSeparatedByString:@"/"] lastObject];
    NSString *fileBaseName = [testImageFileName substringToIndex:[testImageFileName rangeOfString:@"."].location];
    NSString *expectedTextFile = [[NSBundle bundleForClass:[self class]] pathForResource:fileBaseName ofType:@"txt" inDirectory:self.testBase];

    NSString *expectedText;
    if (expectedTextFile) {
      expectedText = [self readFileAsString:expectedTextFile encoding:NSUTF8StringEncoding];
    } else {
      NSString *expectedTextFile = [[NSBundle bundleForClass:[self class]] pathForResource:fileBaseName ofType:@"bin" inDirectory:self.testBase];
      XCTAssertNotNil(expectedTextFile, @"Expected text does not exist");
      expectedText = [self readFileAsString:expectedTextFile encoding:NSISOLatin1StringEncoding];
    }

    NSURL *expectedMetadataFile = [NSURL URLWithString:[[NSBundle bundleForClass:[self class]] pathForResource:fileBaseName ofType:@".metadata.txt" inDirectory:self.testBase]];
    NSMutableDictionary *expectedMetadata = [NSMutableDictionary dictionary];
    if ([fileManager fileExistsAtPath:[expectedMetadataFile path]]) {
      expectedMetadata = [NSMutableDictionary dictionaryWithContentsOfFile:[expectedMetadataFile path]];
    }

    for (int x = 0; x < testCount; x++) {
      float rotation = [(TestResult *)self.testResults[x] rotation];
      ZXImage *rotatedImage = [self rotateImage:image degrees:rotation];
      ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:rotatedImage.cgimage];
      ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:[[ZXHybridBinarizer alloc] initWithSource:source]];
      BOOL misread;
      if ([self decode:bitmap rotation:rotation expectedText:expectedText expectedMetadata:expectedMetadata tryHarder:NO misread:&misread]) {
        passedCounts.array[x]++;
      } else if (misread) {
        misreadCounts.array[x]++;
      } else {
        NSLog(@"could not read at rotation %f", rotation);
      }

      if ([self decode:bitmap rotation:rotation expectedText:expectedText expectedMetadata:expectedMetadata tryHarder:YES misread:&misread]) {
        tryHarderCounts.array[x]++;
      } else if (misread) {
        tryHarderMisreadCounts.array[x]++;
      } else {
        NSLog(@"could not read at rotation %f w/TH", rotation);
      }
    }
  }

  // Print the results of all tests first
  int totalFound = 0;
  int totalMustPass = 0;
  int totalMisread = 0;
  int totalMaxMisread = 0;

  for (int x = 0; x < testCount; x++) {
    TestResult *testResult = self.testResults[x];
    NSLog(@"Rotation %d degrees:", (int) testResult.rotation);
    NSLog(@"  %d of %d images passed (%d required)",
          passedCounts.array[x], (int)imageFiles.count, testResult.mustPassCount);
    int failed = (int)imageFiles.count - passedCounts.array[x];
    NSLog(@"    %d failed due to misreads, %d not detected",
          misreadCounts.array[x], failed - misreadCounts.array[x]);
    NSLog(@"  %d of %d images passed with try harder (%d required)",
          tryHarderCounts.array[x], (int)imageFiles.count, testResult.tryHarderCount);
    failed = (int)imageFiles.count - tryHarderCounts.array[x];
    NSLog(@"    %d failed due to misreads, %d not detected",
          tryHarderMisreadCounts.array[x], failed - tryHarderMisreadCounts.array[x]);
    totalFound += passedCounts.array[x] + tryHarderCounts.array[x];
    totalMustPass += testResult.mustPassCount + testResult.tryHarderCount;
    totalMisread += misreadCounts.array[x] + tryHarderMisreadCounts.array[x];
    totalMaxMisread += testResult.maxMisreads + testResult.maxTryHarderMisreads;
  }

  int totalTests = (int)imageFiles.count * testCount * 2;
  NSLog(@"TOTALS:\nDecoded %d images out of %d (%d%%, %d required)",
        totalFound, totalTests, totalFound * 100 / totalTests, totalMustPass);
  if (totalFound > totalMustPass) {
    NSLog(@"  +++ Test too lax by %d images", totalFound - totalMustPass);
  } else if (totalFound < totalMustPass) {
    NSLog(@"  --- Test failed by %d images", totalMustPass - totalFound);
  }

  if (totalMisread < totalMaxMisread) {
    NSLog(@"  +++ Test expects too many misreads by %d images", totalMaxMisread - totalMisread);
  } else if (totalMisread > totalMaxMisread) {
    NSLog(@"  --- Test had too many misreads by %d images", totalMisread - totalMaxMisread);
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

- (BOOL)decode:(ZXBinaryBitmap *)source rotation:(float)rotation expectedText:(NSString *)expectedText expectedMetadata:(NSMutableDictionary *)expectedMetadata tryHarder:(BOOL)tryHarder misread:(BOOL *)misread {
  NSString *suffix = [NSString stringWithFormat:@" (%@rotation: %d)", tryHarder ? @"try harder, " : @"", (int) rotation];
  *misread = NO;

  ZXDecodeHints *hints = [ZXDecodeHints hints];
  if (tryHarder) {
    hints.tryHarder = YES;
  }

  ZXResult *result = [self.barcodeReader decode:source hints:hints error:nil];
  if (!result) {
    return NO;
  }

  if (self.expectedFormat != result.barcodeFormat) {
    NSLog(@"Format mismatch: expected '%@' but got '%@'%@",
          [[self class] barcodeFormatAsString:self.expectedFormat], [[self class] barcodeFormatAsString:result.barcodeFormat], suffix);
    *misread = YES;
    return NO;
  }

  NSString *resultText = result.text;
  if (![expectedText isEqualToString:resultText]) {
    NSLog(@"Content mismatch: expected '%@' but got '%@'%@", expectedText, resultText, suffix);
    *misread = YES;
    return NO;
  }

  NSMutableDictionary *resultMetadata = result.resultMetadata;
  for (id keyObj in [expectedMetadata allKeys]) {
    ZXResultMetadataType key = [keyObj intValue];
    id expectedValue = expectedMetadata[keyObj];
    id actualValue = resultMetadata[keyObj];
    if (![expectedValue isEqual:actualValue]) {
      NSLog(@"Metadata mismatch: for key '%d' expected '%@' but got '%@'", key, expectedValue, actualValue);
      *misread = YES;
      return NO;
    }
  }

  return YES;
}

- (NSString *)readFileAsString:(NSString *)file encoding:(NSStringEncoding)encoding {
   NSString *stringContents = [NSString stringWithContentsOfFile:file encoding:encoding error:nil];
  if ([stringContents hasSuffix:@"\n"]) {
    NSLog(@"String contents of file %@ end with a newline. This may not be intended and cause a test failure", file);
  }
  return stringContents;
}

// Adapted from http://blog.coriolis.ch/2009/09/04/arbitrary-rotation-of-a-cgimage/ and https://github.com/JanX2/CreateRotateWriteCGImage
- (ZXImage *)rotateImage:(ZXImage *)original degrees:(float)degrees {
  if (degrees == 0.0f) {
    return original;
  }
  double radians = -1 * degrees * (M_PI / 180);

  CGRect imgRect = CGRectMake(0, 0, original.width, original.height);
  CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
  CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(NULL,
                                               rotatedRect.size.width,
                                               rotatedRect.size.height,
                                               CGImageGetBitsPerComponent(original.cgimage),
                                               0,
                                               colorSpace,
                                               kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
  CGContextSetAllowsAntialiasing(context, FALSE);
  CGContextSetInterpolationQuality(context, kCGInterpolationNone);
  CGColorSpaceRelease(colorSpace);

  CGContextTranslateCTM(context,
                        +(rotatedRect.size.width/2),
                        +(rotatedRect.size.height/2));
  CGContextRotateCTM(context, radians);

  CGContextDrawImage(context, CGRectMake(-imgRect.size.width / 2,
                                         -imgRect.size.height / 2,
                                         imgRect.size.width,
                                         imgRect.size.height),
                     original.cgimage);

  CGImageRef rotatedImage = CGBitmapContextCreateImage(context);

  CFRelease(context);

  return [[ZXImage alloc] initWithCGImageRef:rotatedImage];
}

@end

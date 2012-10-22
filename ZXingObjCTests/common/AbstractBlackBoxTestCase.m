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
#import "ZXBinaryBitmap.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXDecodeHints.h"
#import "ZXHybridBinarizer.h"
#import "ZXResult.h"

@interface AbstractBlackBoxTestCase ()

@property (nonatomic, retain) id<ZXReader> barcodeReader;
@property (nonatomic, assign) ZXBarcodeFormat expectedFormat;
@property (nonatomic, copy) NSString * testBase;
@property (nonatomic, retain) NSMutableArray * testResults;

- (void)runTests;
- (NSString*)pathInBundle:(NSURL*)file;
- (void)testBlackBoxCountingResults:(BOOL)assertOnFailure;

@end

@implementation AbstractBlackBoxTestCase

@synthesize barcodeReader;
@synthesize expectedFormat;
@synthesize testBase;
@synthesize testResults;

- (id)initWithInvocation:(NSInvocation *)anInvocation testBasePathSuffix:(NSString *)testBasePathSuffix barcodeReader:(id<ZXReader>)reader expectedFormat:(ZXBarcodeFormat)format {
  if (self = [super initWithInvocation:anInvocation]) {
    self.testBase = testBasePathSuffix;
    self.barcodeReader = reader;
    self.expectedFormat = format;
    self.testResults = [NSMutableArray array];
  }

  return self;
}

- (void)dealloc {
  [barcodeReader release];
  [testBase release];
  [testResults release];

  [super dealloc];
}

- (void)addTest:(int)mustPassCount tryHarderCount:(int)tryHarderCount rotation:(float)rotation {
  [self addTest:mustPassCount tryHarderCount:tryHarderCount maxMisreads:0 maxTryHarderMisreads:0 rotation:rotation];
}

/**
 * Adds a new test for the current directory of images.
 */
- (void)addTest:(int)mustPassCount tryHarderCount:(int)tryHarderCount maxMisreads:(int)maxMisreads maxTryHarderMisreads:(int)maxTryHarderMisreads rotation:(float)rotation {
  [self.testResults addObject:[[[TestResult alloc] initWithMustPassCount:mustPassCount tryHarderCount:tryHarderCount maxMisreads:maxMisreads maxTryHarderMisreads:maxTryHarderMisreads rotation:rotation] autorelease]];
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

+ (NSString*)barcodeFormatAsString:(ZXBarcodeFormat)format {
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

- (NSString*)pathInBundle:(NSURL*)file {
  NSInteger startOfResources = [[file path] rangeOfString:@"Resources"].location;
  if (startOfResources == NSNotFound) {
    return [file path];
  } else {
    return [[file path] substringFromIndex:startOfResources];
  }
}

- (void)testBlackBoxCountingResults:(BOOL)assertOnFailure {
  if (testResults.count == 0) {
    STFail(@"No test results");
  }

  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray * imageFiles = [self imageFiles];
  int testCount = [self.testResults count];

  int passedCounts[testCount];
  memset(passedCounts, 0, testCount * sizeof(int));

  int misreadCounts[testCount];
  memset(misreadCounts, 0, testCount * sizeof(int));

  int tryHarderCounts[testCount];
  memset(tryHarderCounts, 0, testCount * sizeof(int));

  int tryHarderMisreadCounts[testCount];
  memset(tryHarderMisreadCounts, 0, testCount * sizeof(int));

  for (NSURL * testImage in imageFiles) {
    NSLog(@"Starting %@", [self pathInBundle:testImage]);
    
    ZXImage * image = [[ZXImage alloc] initWithURL:testImage];

    NSString * testImageFileName = [[[testImage path] componentsSeparatedByString:@"/"] lastObject];
    NSString * fileBaseName = [testImageFileName substringToIndex:[testImageFileName rangeOfString:@"."].location];
    NSString * expectedTextFile = [[NSBundle bundleForClass:[self class]] pathForResource:fileBaseName ofType:@"txt" inDirectory:testBase];

    NSString * expectedText;
    if (expectedTextFile) {
      expectedText = [NSString stringWithContentsOfFile:expectedTextFile encoding:NSUTF8StringEncoding error:nil];
    } else {
      NSString * expectedTextFile = [[NSBundle bundleForClass:[self class]] pathForResource:fileBaseName ofType:@"bin" inDirectory:testBase];
      STAssertNotNil(expectedTextFile, @"Expected text does not exist");
      expectedText = [NSString stringWithContentsOfFile:expectedTextFile encoding:NSISOLatin1StringEncoding error:nil];
    }

    NSURL * expectedMetadataFile = [NSURL URLWithString:[[NSBundle bundleForClass:[self class]] pathForResource:fileBaseName ofType:@".metadata.txt" inDirectory:testBase]];
    NSMutableDictionary * expectedMetadata = [NSMutableDictionary dictionary];
    if ([fileManager fileExistsAtPath:[expectedMetadataFile path]]) {
      expectedMetadata = [NSMutableDictionary dictionaryWithContentsOfFile:[expectedMetadataFile path]];
    }

    for (int x = 0; x < testCount; x++) {
      float rotation = [[self.testResults objectAtIndex:x] rotation];
      ZXImage * rotatedImage = [self rotateImage:image degrees:rotation];
      ZXLuminanceSource * source = [[[ZXCGImageLuminanceSource alloc] initWithCGImage:rotatedImage.cgimage] autorelease];
      ZXBinaryBitmap * bitmap = [[[ZXBinaryBitmap alloc] initWithBinarizer:[[[ZXHybridBinarizer alloc] initWithSource:source] autorelease]] autorelease];
      BOOL misread;
      if ([self decode:bitmap rotation:rotation expectedText:expectedText expectedMetadata:expectedMetadata tryHarder:NO misread:&misread]) {
        passedCounts[x]++;
      } else if(misread) {
        misreadCounts[x]++;
      }

      if ([self decode:bitmap rotation:rotation expectedText:expectedText expectedMetadata:expectedMetadata tryHarder:YES misread:&misread]) {
        tryHarderCounts[x]++;
      } else if(misread) {
        tryHarderMisreadCounts[x]++;
      }
    }

    [image release];
  }

  // Print the results of all tests first
  int totalFound = 0;
  int totalMustPass = 0;
  int totalMisread = 0;
  int totalMaxMisread = 0;

  for (int x = 0; x < testCount; x++) {
    TestResult* testResult = [self.testResults objectAtIndex:x];
    NSLog(@"Rotation %d degrees:", (int) testResult.rotation);
    NSLog(@"  %d of %d images passed (%d required)",
          passedCounts[x], imageFiles.count, testResult.mustPassCount);
    int failed = imageFiles.count - passedCounts[x];
    NSLog(@"    %d failed due to misreads, %d not detected",
          misreadCounts[x], failed - misreadCounts[x]);
    NSLog(@"  %d of %d images passed with try harder (%d required)",
          tryHarderCounts[x], imageFiles.count, testResult.tryHarderCount);
    failed = imageFiles.count - tryHarderCounts[x];
    NSLog(@"    %d failed due to misreads, %d not detected",
          tryHarderMisreadCounts[x], failed - tryHarderMisreadCounts[x]);
    totalFound += passedCounts[x] + tryHarderCounts[x];
    totalMustPass += testResult.mustPassCount + testResult.tryHarderCount;
    totalMisread += misreadCounts[x] + tryHarderMisreadCounts[x];
    totalMaxMisread += testResult.maxMisreads + testResult.maxTryHarderMisreads;
  }

  int totalTests = imageFiles.count * testCount * 2;
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
      TestResult* testResult = [self.testResults objectAtIndex:x];
      NSString* label = [NSString stringWithFormat:@"Rotation %f degrees: Too many images failed", testResult.rotation];
      STAssertTrue(passedCounts[x] >= testResult.mustPassCount, label);
      STAssertTrue(tryHarderCounts[x] >= testResult.tryHarderCount, @"Try harder, %@", label);
      label = [NSString stringWithFormat:@"Rotation %f degrees: Too many images misread", testResult.rotation];
      STAssertTrue(misreadCounts[x] <= testResult.maxMisreads, label);
      STAssertTrue(tryHarderMisreadCounts[x] <= testResult.maxTryHarderMisreads, @"Try harder, %@", label);
    }
  }
}

- (BOOL)decode:(ZXBinaryBitmap *)source rotation:(float)rotation expectedText:(NSString *)expectedText expectedMetadata:(NSMutableDictionary *)expectedMetadata tryHarder:(BOOL)tryHarder misread:(BOOL*)misread {
  NSString * suffix = [NSString stringWithFormat:@" (%@rotation: %d)", tryHarder ? @"try harder, " : @"", (int) rotation];
  *misread = NO;

  ZXDecodeHints * hints = [ZXDecodeHints hints];
  if (tryHarder) {
    hints.tryHarder = YES;
  }

  ZXResult * result = [self.barcodeReader decode:source hints:hints error:nil];
  if (!result) {
    return NO;
  }

  if (self.expectedFormat != result.barcodeFormat) {
    NSLog(@"Format mismatch: expected '%@' but got '%@'%@",
          [[self class] barcodeFormatAsString:expectedFormat], [[self class] barcodeFormatAsString:result.barcodeFormat], suffix);
    *misread = YES;
    return NO;
  }

  NSString * resultText = result.text;
  if (![expectedText isEqualToString:resultText]) {
    NSLog(@"Content mismatch: expected '%@' but got '%@'%@", expectedText, resultText, suffix);
    *misread = YES;
    return NO;
  }

  NSMutableDictionary * resultMetadata = result.resultMetadata;
  for (id keyObj in [expectedMetadata allKeys]) {
    ZXResultMetadataType key = [keyObj intValue];
    id expectedValue = [expectedMetadata objectForKey:keyObj];
    id actualValue = [resultMetadata objectForKey:keyObj];
    if (![expectedValue isEqual:actualValue]) {
      NSLog(@"Metadata mismatch: for key '%d' expected '%@' but got '%@'", key, expectedValue, actualValue);
      *misread = YES;
      return NO;
    }
  }

  return YES;
}

// Adapted from http://blog.coriolis.ch/2009/09/04/arbitrary-rotation-of-a-cgimage/ and https://github.com/JanX2/CreateRotateWriteCGImage
- (ZXImage *)rotateImage:(ZXImage *)original degrees:(float)degrees {
  if (degrees == 0.0f) {
    return original;
  }
  double radians = degrees * M_PI / 180;

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
  radians = -1 * radians;
#endif
  
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
                                               kCGImageAlphaPremultipliedFirst);
  CGContextSetAllowsAntialiasing(context, FALSE);
  CGContextSetInterpolationQuality(context, kCGInterpolationNone);
  CGColorSpaceRelease(colorSpace);

  CGContextTranslateCTM(context,
                        +(rotatedRect.size.width/2),
                        +(rotatedRect.size.height/2));
  CGContextRotateCTM(context, radians);

  CGContextDrawImage(context, CGRectMake(-imgRect.size.width/2, 
                                         -imgRect.size.height/2,
                                         imgRect.size.width, 
                                         imgRect.size.height),
                     original.cgimage);

  CGImageRef rotatedImage = CGBitmapContextCreateImage(context);
  CFMakeCollectable(rotatedImage);

  CFRelease(context);

  return [[[ZXImage alloc] initWithCGImageRef:rotatedImage] autorelease];
}

@end

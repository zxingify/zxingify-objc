#import "AbstractBlackBoxTestCase.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXDecodeHintType.h"
#import "ZXHybridBinarizer.h"
#import "ZXReaderException.h"

@implementation SummaryResults

@synthesize totalFound;
@synthesize totalMustPass;
@synthesize totalTests;

- (id) init {
  if (self = [super init]) {
    totalFound = 0;
    totalMustPass = 0;
    totalTests = 0;
  }
  return self;
}

- (id) initWithFound:(int)found mustPass:(int)mustPass total:(int)total {
  if (self = [super init]) {
    totalFound = found;
    totalMustPass = mustPass;
    totalTests = total;
  }
  return self;
}

- (void) add:(SummaryResults *)other {
  totalFound += other.totalFound;
  totalMustPass += other.totalMustPass;
  totalTests += other.totalTests;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"\nSUMMARY RESULTS:\n  Decoded %d images out of %d (%d%%, %d required)", totalFound, totalTests, (totalFound * 100 / totalTests), totalMustPass];
}

@end

@implementation TestResult

@synthesize mustPassCount;
@synthesize tryHarderCount;
@synthesize rotation;

- (id) initWithMustPassCount:(int)mustPass tryHarderCount:(int)tryHarder rotation:(float)rot {
  if (self = [super init]) {
    mustPassCount = mustPass;
    tryHarderCount = tryHarder;
    rotation = rot;
  }
  return self;
}

@end

@implementation AbstractBlackBoxTestCase

static NSMutableDictionary* TRY_HARDER_HINT = nil;

+ (void) initialize {
  if (!TRY_HARDER_HINT) {
    TRY_HARDER_HINT = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], [NSNumber numberWithInt:kDecodeHintTypeTryHarder], nil];
  }
}

- (id) initWithInvocation:(NSInvocation *)anInvocation testBasePathSuffix:(NSString *)testBasePathSuffix barcodeReader:(id<ZXReader>)reader expectedFormat:(ZXBarcodeFormat)format {
  if (self = [super initWithInvocation:anInvocation]) {
    testBase = [testBasePathSuffix retain];
    barcodeReader = [reader retain];
    expectedFormat = format;
    testResults = [[NSMutableArray alloc] init];
  }
  return self;
}


/**
 * Adds a new test for the current directory of images.
 * 
 * @param mustPassCount The number of images which must decode for the test to pass.
 * @param tryHarderCount The number of images which must pass using the try harder flag.
 * @param rotation The rotation in degrees clockwise to use for this test.
 */
- (void) addTest:(int)mustPassCount tryHarderCount:(int)tryHarderCount rotation:(float)rotation {
  [testResults addObject:[[[TestResult alloc] initWithMustPassCount:mustPassCount tryHarderCount:tryHarderCount rotation:rotation] autorelease]];
}

- (NSArray *) imageFiles {
  NSMutableArray *imageFiles = [NSMutableArray array];
  for (NSString *file in [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:nil inDirectory:testBase]) {
    if ([[file pathExtension] isEqualToString:@"jpg"] ||
        [[file pathExtension] isEqualToString:@"jpeg"] ||
        [[file pathExtension] isEqualToString:@"gif"] ||
        [[file pathExtension] isEqualToString:@"png"]) {
      [imageFiles addObject:[NSURL fileURLWithPath:file]];
    }
  }

  return imageFiles;
}

- (id<ZXReader>) reader {
  return barcodeReader;
}

- (NSMutableDictionary *) hints {
  return nil;
}

- (void) testBlackBox {
  [self testBlackBoxCountingResults:YES];
}

- (SummaryResults *) testBlackBoxCountingResults:(BOOL)assertOnFailure {
  if (testResults.count == 0) {
//    STFail(@"No test results");
    return nil;
  }
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray * imageFiles = [self imageFiles];
  int testCount = [testResults count];
  int passedCounts[testCount];
  for (int i = 0; i < testCount; i++) {
    passedCounts[i] = 0;
  }

  int tryHarderCounts[testCount];
  for (int i = 0; i < testCount; i++) {
    tryHarderCounts[i] = 0;
  }

  for (NSURL * testImage in imageFiles) {
    NSLog(@"Starting %@", [testImage path]);
    
    ZXImage * image = [[ZXImage alloc] initWithURL:testImage];

    NSString * testImageFileName = [[[testImage path] componentsSeparatedByString:@"/"] lastObject];
    NSString * fileBaseName = [testImageFileName substringToIndex:[testImageFileName rangeOfString:@"."].location];
    NSURL * expectedTextFile = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:fileBaseName ofType:@"txt" inDirectory:testBase]];
    NSString * expectedText = [NSString stringWithContentsOfURL:expectedTextFile encoding:NSUTF8StringEncoding error:nil];

    NSURL * expectedMetadataFile = [NSURL URLWithString:[[NSBundle bundleForClass:[self class]] pathForResource:fileBaseName ofType:@".metadata.txt" inDirectory:testBase]];
    NSMutableDictionary * expectedMetadata = [NSMutableDictionary dictionary];
    if ([fileManager fileExistsAtPath:[expectedMetadataFile path]]) {
      expectedMetadata = [NSMutableDictionary dictionaryWithContentsOfFile:[expectedMetadataFile path]];
    }

    for (int x = 0; x < testCount; x++) {
      float rotation = [[testResults objectAtIndex:x] rotation];
      ZXImage * rotatedImage = [self rotateImage:image degrees:rotation];
      ZXLuminanceSource * source = [[[ZXCGImageLuminanceSource alloc] initWithCGImage:rotatedImage.cgimage] autorelease];
      ZXBinaryBitmap * bitmap = [[[ZXBinaryBitmap alloc] initWithBinarizer:[[[ZXHybridBinarizer alloc] initWithSource:source] autorelease]] autorelease];
      if ([self decode:bitmap rotation:rotation expectedText:expectedText expectedMetadata:expectedMetadata tryHarder:NO]) {
        passedCounts[x]++;
      }
      if ([self decode:bitmap rotation:rotation expectedText:expectedText expectedMetadata:expectedMetadata tryHarder:YES]) {
        tryHarderCounts[x]++;
      }
    }

    [image release];
  }

  int totalFound = 0;
  int totalMustPass = 0;

  for (int x = 0; x < testCount; x++) {
    NSLog(@"Rotation %f degrees:", [[testResults objectAtIndex:x] rotation]);
    NSLog(@"\t%d of %d images passed (%d required)", passedCounts[x], [imageFiles count], [[testResults objectAtIndex:x] mustPassCount]);
    NSLog(@"\t%d of %d images passed with try harder (%d required)", tryHarderCounts[x], [imageFiles count], [[testResults objectAtIndex:x] tryHarderCount]);
    totalFound += passedCounts[x];
    totalFound += tryHarderCounts[x];
    totalMustPass += [[testResults objectAtIndex:x] mustPassCount];
    totalMustPass += [[testResults objectAtIndex:x] tryHarderCount];
  }

  int totalTests = [imageFiles count] * testCount * 2;
  NSLog(@"TOTALS:\n  Decoded %d images out of %d (%d%%, %d required)", totalFound, totalTests, (totalFound * 100 / totalTests), totalMustPass);
  if (totalFound > totalMustPass) {
    NSLog(@"  *** Test too lax by %d images", totalFound - totalMustPass);
  } else if (totalFound < totalMustPass) {
    NSLog(@"  *** Test failed by %d images", totalMustPass - totalFound);
  }

  if (assertOnFailure) {
    for (int x = 0; x < testCount; x++) {
      STAssertTrue(passedCounts[x] >= [[testResults objectAtIndex:x] mustPassCount], @"Rotation %f degrees: Too many images failed", [[testResults objectAtIndex:x] rotation]);
      STAssertTrue(tryHarderCounts[x] >= [[testResults objectAtIndex:x] tryHarderCount], @"Try harder, Rotation %f degrees: Too many images failed", [[testResults objectAtIndex:x] rotation]);
    }
  }

  return [[[SummaryResults alloc] initWithFound:totalFound mustPass:totalMustPass total:totalTests] autorelease];
}

- (BOOL) decode:(ZXBinaryBitmap *)source rotation:(float)rotation expectedText:(NSString *)expectedText expectedMetadata:(NSMutableDictionary *)expectedMetadata tryHarder:(BOOL)tryHarder {
  ZXResult * result = nil;
  NSString * suffix = [NSString stringWithFormat:@" (%@rotation: %f)", (tryHarder ? @"try harder, " : @""), rotation];

  @try {
    NSMutableDictionary * hints = [self hints];
    if (tryHarder) {
      if (hints == nil) {
        hints = TRY_HARDER_HINT;
      } else {
        [hints setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:kDecodeHintTypeTryHarder]];
      }
    }
    result = [barcodeReader decode:source hints:hints];
  } @catch (ZXReaderException * re) {
    NSLog(@"%@%@", re, suffix);
    return NO;
  }

  if (expectedFormat != result.barcodeFormat) {
    NSLog(@"Format mismatch: expected '%d' but got '%d'%@", expectedFormat, result.barcodeFormat, suffix);
    return NO;
  }

  NSString * resultText = [result text];
  if (![expectedText isEqualToString:resultText]) {
    NSLog(@"Mismatch: expected '%@' but got '%@'%@", expectedText, resultText, suffix);
    return NO;
  }

  NSMutableDictionary * resultMetadata = [result resultMetadata];
  for (id keyObj in [expectedMetadata allKeys]) {
    ZXResultMetadataType key = [keyObj intValue];
    id expectedValue = [expectedMetadata objectForKey:keyObj];
    id actualValue = [resultMetadata objectForKey:keyObj];
    if (![expectedValue isEqual:actualValue]) {
      NSLog(@"Metadata mismatch: for key '%d' expected '%@' but got '%@'", key, expectedValue, actualValue);
      return NO;
    }
  }

  return YES;
}

// Adapted from http://blog.coriolis.ch/2009/09/04/arbitrary-rotation-of-a-cgimage/ and https://github.com/JanX2/CreateRotateWriteCGImage
- (ZXImage *) rotateImage:(ZXImage *)original degrees:(float)degrees {
  if (degrees == 0.0f) {
    return original;
  } else {
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
}

- (void) dealloc {
  [testBase release];
  [barcodeReader release];
  [testResults release];
  [super dealloc];
}

@end

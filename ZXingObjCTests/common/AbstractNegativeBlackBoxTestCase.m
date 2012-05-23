#import "AbstractNegativeBlackBoxTestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXBinaryBitmap.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXHybridBinarizer.h"
#import "ZXLuminanceSource.h"
#import "ZXMultiFormatReader.h"
#import "ZXResult.h"

@interface NegativeTestResult : NSObject

@property (nonatomic, assign) int falsePositivesAllowed;
@property (nonatomic, assign) float rotation;

- (id)initWithFalsePositivesAllowed:(int)falsePositivesAllowed rotation:(float)rotation;

@end

@implementation NegativeTestResult

@synthesize falsePositivesAllowed;
@synthesize rotation;

- (id)initWithFalsePositivesAllowed:(int)_falsePositivesAllowed rotation:(float)_rotation {
  if (self = [super init]) {
    self.falsePositivesAllowed = _falsePositivesAllowed;
    self.rotation = _rotation;
  }

  return self;
}

@end

@interface AbstractNegativeBlackBoxTestCase ()

@property (nonatomic, retain) NSMutableArray * testResults;

- (BOOL)checkForFalsePositives:(ZXImage*)image rotationInDegrees:(CGFloat)rotationInDegrees;

@end

@implementation AbstractNegativeBlackBoxTestCase

@synthesize testResults;

static ZXDecodeHints* TRY_HARDER_HINT = nil;

+ (void)initialize {
  if (!TRY_HARDER_HINT) {
    TRY_HARDER_HINT = [[ZXDecodeHints alloc] init];
    TRY_HARDER_HINT.tryHarder = YES;
  }
}

// Use the multiformat reader to evaluate all decoders in the system.
- (id)initWithInvocation:(NSInvocation *)anInvocation testBasePathSuffix:(NSString *)testBasePathSuffix {
  if (self = [super initWithInvocation:anInvocation testBasePathSuffix:testBasePathSuffix barcodeReader:[[[ZXMultiFormatReader alloc] init] autorelease] expectedFormat:0]) {
    self.testResults = [NSMutableArray array];
  }

  return self;
}

- (void)dealloc {
  [testResults release];

  [super dealloc];
}

- (void)addTest:(int)falsePositivesAllowed rotation:(float)rotation {
  [self.testResults addObject:[[[NegativeTestResult alloc] initWithFalsePositivesAllowed:falsePositivesAllowed rotation:rotation] autorelease]];
}

- (void)runTests {
  if (self.testResults.count == 0) {
    STFail(@"No test results");
  }

  NSArray * imageFiles = [self imageFiles];
  int falsePositives[self.testResults.count];
  for (int i = 0; i < self.testResults.count; i++) {
    falsePositives[i] = 0;
  }

  for (NSURL *testImage in imageFiles) {
    NSLog(@"Starting %@", [testImage path]);

    ZXImage * image = [[ZXImage alloc] initWithURL:testImage];
    for (int x = 0; x < self.testResults.count; x++) {
      NegativeTestResult* testResult = [self.testResults objectAtIndex:x];
      if (![self checkForFalsePositives:image rotationInDegrees:testResult.rotation]) {
        falsePositives[x]++;
      }
    }

    [image release];
  }

  for (int x = 0; x < self.testResults.count; x++) {
    NegativeTestResult* testResult = [self.testResults objectAtIndex:x];
    NSLog(@"Rotation %f degrees: %d of %d images were false positives (%d allowed)", testResult.rotation,
          falsePositives[x], imageFiles.count, testResult.falsePositivesAllowed);
    STAssertTrue(falsePositives[x] <= testResult.falsePositivesAllowed,
                 @"Rotation %f degrees: Too many false positives found", testResult.rotation);
  }
}

/**
 * Make sure ZXing does NOT find a barcode in the image.
 */
- (BOOL)checkForFalsePositives:(ZXImage*)image rotationInDegrees:(CGFloat)rotationInDegrees {
  ZXImage * rotatedImage = [self rotateImage:image degrees:rotationInDegrees];
  ZXLuminanceSource * source = [[[ZXCGImageLuminanceSource alloc] initWithCGImage:rotatedImage.cgimage] autorelease];
  ZXBinaryBitmap * bitmap = [[[ZXBinaryBitmap alloc] initWithBinarizer:[[[ZXHybridBinarizer alloc] initWithSource:source] autorelease]] autorelease];
  NSError* error = nil;
  ZXResult * result = [self.barcodeReader decode:bitmap error:&error];
  if (result) {
    NSLog(@"Found false positive: '%@' with format '%d' (rotation: %f)", result.text, result.barcodeFormat, rotationInDegrees);
    return NO;
  }

  // Try "try harder" getMode
  result = [self.barcodeReader decode:bitmap hints:TRY_HARDER_HINT error:&error];
  if (result) {
    NSLog(@"Try harder found false positive: '%@' with format '%d' (rotation: %f)", result.text, result.barcodeFormat, rotationInDegrees);
    return NO;
  }
  return YES;
}

@end

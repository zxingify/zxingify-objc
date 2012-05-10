#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "ZXBarcodeFormat.h"
#import "ZXDecodeHints.h"
#import "ZXImage.h"
#import "ZXReader.h"

@interface SummaryResults : NSObject {
  int totalFound;
  int totalMustPass;
  int totalTests;
}

@property (nonatomic, readonly) int totalFound;
@property (nonatomic, readonly) int totalMustPass;
@property (nonatomic, readonly) int totalTests;

- (id) initWithFound:(int)found mustPass:(int)mustPass total:(int)total;
- (void) add:(SummaryResults *)other;

@end

@interface TestResult : NSObject {
  int mustPassCount;
  int tryHarderCount;
  float rotation;
}

@property(nonatomic, readonly) int mustPassCount;
@property(nonatomic, readonly) int tryHarderCount;
@property(nonatomic, readonly) float rotation;

- (id) initWithMustPassCount:(int)mustPassCount tryHarderCount:(int)tryHarderCount rotation:(float)rotation;

@end

/**
 * @author Sean Owen
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface AbstractBlackBoxTestCase : SenTestCase {
  NSString * testBase;
  id<ZXReader> barcodeReader;
  ZXBarcodeFormat expectedFormat;
  NSMutableArray * testResults;
}

+ (void) initialize;
- (id) initWithInvocation:(NSInvocation *)anInvocation testBasePathSuffix:(NSString *)testBasePathSuffix barcodeReader:(id<ZXReader>)barcodeReader expectedFormat:(ZXBarcodeFormat)expectedFormat;
- (void) addTest:(int)mustPassCount tryHarderCount:(int)tryHarderCount rotation:(float)rotation;
- (NSArray *) imageFiles;
- (id<ZXReader>) reader;
- (ZXDecodeHints *) hints;
- (void) runTests;
- (SummaryResults *) testBlackBoxCountingResults:(BOOL)assertOnFailure;
- (ZXImage *) rotateImage:(ZXImage *)original degrees:(float)degrees;

@end

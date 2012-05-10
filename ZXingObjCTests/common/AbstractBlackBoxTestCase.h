#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "ZXBarcodeFormat.h"
#import "ZXDecodeHints.h"
#import "ZXImage.h"
#import "ZXReader.h"

@interface TestResult : NSObject

@property (nonatomic, readonly) int mustPassCount;
@property (nonatomic, readonly) int tryHarderCount;
@property (nonatomic, readonly) float rotation;

- (id)initWithMustPassCount:(int)mustPassCount tryHarderCount:(int)tryHarderCount rotation:(float)rotation;

@end

@interface AbstractBlackBoxTestCase : SenTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation testBasePathSuffix:(NSString *)testBasePathSuffix barcodeReader:(id<ZXReader>)barcodeReader expectedFormat:(ZXBarcodeFormat)expectedFormat;
- (void)addTest:(int)mustPassCount tryHarderCount:(int)tryHarderCount rotation:(float)rotation;
- (void)runTests;

@end

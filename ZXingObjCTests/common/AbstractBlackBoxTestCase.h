#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "ZXBarcodeFormat.h"
#import "ZXDecodeHints.h"
#import "ZXImage.h"
#import "ZXReader.h"

@interface AbstractBlackBoxTestCase : SenTestCase

@property (nonatomic, retain, readonly) id<ZXReader> barcodeReader;

- (id)initWithInvocation:(NSInvocation *)anInvocation testBasePathSuffix:(NSString *)testBasePathSuffix barcodeReader:(id<ZXReader>)barcodeReader expectedFormat:(ZXBarcodeFormat)expectedFormat;
- (void)addTest:(int)mustPassCount tryHarderCount:(int)tryHarderCount rotation:(float)rotation;
- (void)runTests;

- (ZXDecodeHints *)hints;
- (NSArray *)imageFiles;
- (ZXImage *)rotateImage:(ZXImage *)original degrees:(float)degrees;

@end

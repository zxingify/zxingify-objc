#import "RSSExpandedImage2resultTestCase.h"
#import "ZXBinaryBitmap.h"
#import "ZXBitArrayBuilder.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXExpandedProductParsedResult.h"
#import "ZXGlobalHistogramBinarizer.h"
#import "ZXImage.h"
#import "ZXResultParser.h"
#import "ZXRSSExpandedReader.h"

@interface RSSExpandedImage2resultTestCase ()

- (void)assertCorrectImage2result:(NSString*)path expected:(ZXExpandedProductParsedResult*)expected;

@end

@implementation RSSExpandedImage2resultTestCase

- (void)testDecodeRow2result_2 {
  // (01)90012345678908(3103)001750
  NSString* path = @"Resources/blackbox/rssexpanded-1/2.jpg";
  ZXExpandedProductParsedResult* expected =
    [[[ZXExpandedProductParsedResult alloc] initWithProductID:@"90012345678908" sscc:@"-" lotNumber:@"-" productionDate:@"-" packagingDate:@"-" bestBeforeDate:@"-" expirationDate:@"-" weight:@"001750" weightType:KILOGRAM weightIncrement:@"3" price:@"-" priceIncrement:@"-" priceCurrency:@"-" uncommonAIs:[NSMutableDictionary dictionary]] autorelease];

  [self assertCorrectImage2result:path expected:expected];
}

- (void)assertCorrectImage2result:(NSString*)path expected:(ZXExpandedProductParsedResult*)expected {
  ZXRSSExpandedReader* rssExpandedReader = [[[ZXRSSExpandedReader alloc] init] autorelease];

  ZXImage* image = [[[ZXImage alloc] initWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:path withExtension:nil]] autorelease];
  ZXBinaryBitmap* binaryMap = [[[ZXBinaryBitmap alloc] initWithBinarizer:[[[ZXGlobalHistogramBinarizer alloc] initWithSource:[[[ZXCGImageLuminanceSource alloc] initWithZXImage:image] autorelease]] autorelease]] autorelease];
  int rowNumber = binaryMap.height / 2;
  ZXBitArray* row = [binaryMap blackRow:rowNumber row:nil error:nil];

  ZXResult* theResult = [rssExpandedReader decodeRow:rowNumber row:row hints:nil error:nil];

  STAssertEquals(theResult.barcodeFormat, kBarcodeFormatRSSExpanded, @"Expected format to be kBarcodeFormatRSSExpanded");

  ZXParsedResult* result = [ZXResultParser parseResult:theResult];

  STAssertEqualObjects(result, expected, @"Result does not match expected");
}

@end

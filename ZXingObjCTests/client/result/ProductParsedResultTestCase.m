#import "ProductParsedResultTestCase.h"
#import "ZXProductParsedResult.h"
#import "ZXResultParser.h"

@interface ProductParsedResultTestCase ()

- (void)doTestWithContents:(NSString*)contents
                normalized:(NSString*)normalized
                    format:(ZXBarcodeFormat)format;

@end

@implementation ProductParsedResultTestCase

- (void)testProduct {
  [self doTestWithContents:@"123456789012" normalized:@"123456789012" format:kBarcodeFormatUPCA];
  [self doTestWithContents:@"00393157" normalized:@"00393157" format:kBarcodeFormatEan8];
  [self doTestWithContents:@"5051140178499" normalized:@"5051140178499" format:kBarcodeFormatEan13];
  [self doTestWithContents:@"01234565" normalized:@"012345000065" format:kBarcodeFormatUPCE];
}

- (void)doTestWithContents:(NSString*)contents
                normalized:(NSString*)normalized
                    format:(ZXBarcodeFormat)format {
  ZXResult* fakeResult = [[[ZXResult alloc] initWithText:contents rawBytes:NULL length:0 resultPoints:nil format:format] autorelease];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeProduct, @"Types don't match");
  ZXProductParsedResult* productResult = (ZXProductParsedResult*)result;
  STAssertEqualObjects(productResult.productID, contents, @"Contents don't match");
  STAssertEqualObjects(productResult.normalizedProductID, normalized, @"Normalized doesn't match");
}

@end

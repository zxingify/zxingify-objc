#import "ExpandedProductParsedResultTestCase.h"
#import "ZXBarcodeFormat.h"
#import "ZXExpandedProductParsedResult.h"
#import "ZXExpandedProductResultParser.h"
#import "ZXResult.h"

@implementation ExpandedProductParsedResultTestCase

- (void)test_RSSExpanded {
  NSString* text = @"(01)66546(13)001205(3932)4455(3102)6544(123)544654";
  NSString* productID = @"66546";
  NSString* sscc = @"-";
  NSString* lotNumber = @"-";
  NSString* productionDate = @"-";
  NSString* packagingDate = @"001205";
  NSString* bestBeforeDate = @"-";
  NSString* expirationDate = @"-";
  NSString* weight = @"6544";
  NSString* weightType = @"KG";
  NSString* weightIncrement = @"2";
  NSString* price = @"5";
  NSString* priceIncrement = @"2";
  NSString* priceCurrency = @"445";
  NSDictionary* uncommonAIs = [NSDictionary dictionaryWithObject:@"544654" forKey:@"123"];

  ZXResult* result = [[[ZXResult alloc] initWithText:text rawBytes:NULL length:0 resultPoints:nil format:kBarcodeFormatRSSExpanded] autorelease];
  ZXExpandedProductParsedResult* o = [ZXExpandedProductResultParser parse:result];
  STAssertEqualObjects(o.productID, productID, @"Product IDs don't match");
  STAssertEqualObjects(o.sscc, sscc, @"Sscc doesn't match");
  STAssertEqualObjects(o.lotNumber, lotNumber, @"Lot numbers don't match");
  STAssertEqualObjects(o.productionDate, productionDate, @"Production dates don't match");
  STAssertEqualObjects(o.packagingDate, packagingDate, @"Packaging dates don't match");
  STAssertEqualObjects(o.bestBeforeDate, bestBeforeDate, @"Best before dates don't match");
  STAssertEqualObjects(o.expirationDate, expirationDate, @"Expiration dates don't match");
  STAssertEqualObjects(o.weight, weight, @"Weights don't match");
  STAssertEqualObjects(o.weightType, weightType, @"Weight types don't match");
  STAssertEqualObjects(o.weightIncrement, weightIncrement, @"Weight increments don't match");
  STAssertEqualObjects(o.price, price, @"Prices don't match");
  STAssertEqualObjects(o.priceIncrement, priceIncrement, @"Price increments don't match");
  STAssertEqualObjects(o.priceCurrency, priceCurrency, @"Price currencies don't match");
  STAssertEqualObjects(o.uncommonAIs, uncommonAIs, @"Uncommon AIs don't match");
}

@end

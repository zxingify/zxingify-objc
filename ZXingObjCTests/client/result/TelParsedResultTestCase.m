#import "TelParsedResultTestCase.h"
#import "ZXResultParser.h"
#import "ZXTelParsedResult.h"

@interface TelParsedResultTestCase ()

- (void)doTestWithContents:(NSString*)contents number:(NSString*)number title:(NSString*)title;

@end

@implementation TelParsedResultTestCase

- (void)testTel {
  [self doTestWithContents:@"tel:+15551212" number:@"+15551212" title:nil];
  [self doTestWithContents:@"tel:2125551212" number:@"2125551212" title:nil];
}

- (void)doTestWithContents:(NSString*)contents number:(NSString*)number title:(NSString*)title {
  ZXResult* fakeResult = [[[ZXResult alloc] initWithText:contents rawBytes:NULL length:0 resultPoints:nil
                                                  format:kBarcodeFormatQRCode] autorelease];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeTel, @"Types don't match");
  ZXTelParsedResult* telResult = (ZXTelParsedResult*)result;
  STAssertEqualObjects(telResult.number, number, @"Numbers don't match");
  STAssertEqualObjects(telResult.title, title, @"Titles don't match");
  STAssertEqualObjects(telResult.telURI, [@"tel:" stringByAppendingString:number], @"Tel URIs don't match");
}

@end

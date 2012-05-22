#import "ZXISBNParsedResult.h"
#import "ZXISBNParsedResultTestCase.h"
#import "ZXResultParser.h"

@interface ZXISBNParsedResultTestCase ()

- (void)doTestWithContents:(NSString*)contents;

@end

@implementation ZXISBNParsedResultTestCase

- (void)testISBN {
  [self doTestWithContents:@"9784567890123"];
}

- (void)doTestWithContents:(NSString*)contents {
  ZXResult* fakeResult = [[[ZXResult alloc] initWithText:contents rawBytes:NULL length:0 resultPoints:nil format:kBarcodeFormatEan13] autorelease];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeISBN, @"Types don't match");
  ZXISBNParsedResult* isbnResult = (ZXISBNParsedResult*)result;
  STAssertEqualObjects(isbnResult.isbn, contents, @"Contents don't match");
}

@end

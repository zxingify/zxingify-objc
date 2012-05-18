#import "SMSMMSParsedResultTestCase.h"
#import "ZXResultParser.h"
#import "ZXSMSParsedResult.h"

@interface SMSMMSParsedResultTestCase ()

- (void)doTestWithContents:(NSString*)contents
                    number:(NSString*)number
                   subject:(NSString*)subject
                      body:(NSString*)body
                       via:(NSString*)via;

- (void)doTestWithContents:(NSString*)contents
                   numbers:(NSArray*)numbers
                   subject:(NSString*)subject
                      body:(NSString*)body
                      vias:(NSArray*)vias;

@end

@implementation SMSMMSParsedResultTestCase

- (void)testSMS {
  [self doTestWithContents:@"sms:+15551212" number:@"+15551212" subject:nil body:nil via:nil];
  [self doTestWithContents:@"sms:+15551212?subject=foo&body=bar" number:@"+15551212" subject:@"foo" body:@"bar" via:nil];
  [self doTestWithContents:@"sms:+15551212;via=999333" number:@"+15551212" subject:nil body:nil via:@"999333"];
}

- (void)testMMS {
  [self doTestWithContents:@"mms:+15551212" number:@"+15551212" subject:nil body:nil via:nil];
  [self doTestWithContents:@"mms:+15551212?subject=foo&body=bar" number:@"+15551212" subject:@"foo" body:@"bar" via:nil];
  [self doTestWithContents:@"mms:+15551212;via=999333" number:@"+15551212" subject:nil body:nil via:@"999333"];
}

- (void)doTestWithContents:(NSString*)contents
                    number:(NSString*)number
                   subject:(NSString*)subject
                      body:(NSString*)body
                       via:(NSString*)via {
  [self doTestWithContents:contents
                   numbers:[NSArray arrayWithObject:number ? number : [NSNull null]]
                   subject:subject
                      body:body
                      vias:[NSArray arrayWithObject:via ? via : [NSNull null]]];
}

- (void)doTestWithContents:(NSString*)contents
                   numbers:(NSArray*)numbers
                   subject:(NSString*)subject
                      body:(NSString*)body
                      vias:(NSArray*)vias {
  ZXResult* fakeResult = [[[ZXResult alloc] initWithText:contents rawBytes:NULL length:0 resultPoints:nil
                                                  format:kBarcodeFormatQRCode] autorelease];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeSMS, @"Types don't match");
  ZXSMSParsedResult* smsResult = (ZXSMSParsedResult*)result;
  STAssertEqualObjects(smsResult.numbers, numbers, @"Numbers don't match");
  STAssertEqualObjects(smsResult.subject, subject, @"Subjects don't match");
  STAssertEqualObjects(smsResult.body, body, @"Bodies don't match");
  STAssertEqualObjects(smsResult.vias, vias, @"Vias don't match");
}

@end

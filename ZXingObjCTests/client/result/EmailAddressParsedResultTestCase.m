#import "EmailAddressParsedResultTestCase.h"
#import "ZXEmailAddressParsedResult.h"
#import "ZXParsedResult.h"
#import "ZXResultParser.h"

@interface EmailAddressParsedResultTestCase ()

- (void)doTestWithContents:(NSString*)contents
                     email:(NSString*)email
                   subject:(NSString*)subject
                      body:(NSString*)body;

@end

@implementation EmailAddressParsedResultTestCase

- (void)testEmailAddress {
  [self doTestWithContents:@"srowen@example.org" email:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"mailto:srowen@example.org" email:@"srowen@example.org" subject:nil body:nil];
}

- (void)testEmailDocomo {
  [self doTestWithContents:@"MATMSG:TO:srowen@example.org;;" email:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"MATMSG:TO:srowen@example.org;SUB:Stuff;;" email:@"srowen@example.org" subject:@"Stuff" body:nil];
  [self doTestWithContents:@"MATMSG:TO:srowen@example.org;SUB:Stuff;BODY:This is some text;;"
                     email:@"srowen@example.org" subject:@"Stuff" body:@"This is some text"];
}

- (void)testSMTP {
  [self doTestWithContents:@"smtp:srowen@example.org" email:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"SMTP:srowen@example.org" email:@"srowen@example.org" subject:nil body:nil];
  [self doTestWithContents:@"SMTP:srowen@example.org:foo" email:@"srowen@example.org" subject:@"foo" body:nil];
  [self doTestWithContents:@"SMTP:srowen@example.org:foo:bar" email:@"srowen@example.org" subject:@"foo" body:@"bar"];
}

- (void)doTestWithContents:(NSString*)contents
                     email:(NSString*)email
                   subject:(NSString*)subject
                      body:(NSString*)body {
  ZXResult* fakeResult = [[[ZXResult alloc] initWithText:contents
                                                rawBytes:NULL
                                                  length:0
                                            resultPoints:nil
                                                  format:kBarcodeFormatQRCode] autorelease];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeEmailAddress, @"Types do not match");
  ZXEmailAddressParsedResult* emailResult = (ZXEmailAddressParsedResult*)result;
  STAssertEqualObjects(emailResult.emailAddress, email, @"Email addresses do not match");
  STAssertEqualObjects(emailResult.mailtoURI, [@"mailto:" stringByAppendingString:emailResult.emailAddress], @"Mailto URIs do not match");
  STAssertEqualObjects(emailResult.subject, subject, @"Subjects do not match");
  STAssertEqualObjects(emailResult.body, body, @"Bodies do not match");
}

@end

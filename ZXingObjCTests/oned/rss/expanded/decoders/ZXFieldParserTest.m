#import "ZXFieldParser.h"
#import "ZXFieldParserTest.h"

@implementation ZXFieldParserTest

- (void)checkFields:(NSString*)expected {
  NSString* field = [[expected stringByReplacingOccurrencesOfString:@"(" withString:@""]
                     stringByReplacingOccurrencesOfString:@")" withString:@""];
  NSString* actual = [ZXFieldParser parseFieldsInGeneralPurpose:field];
  STAssertEqualObjects(actual, expected, @"Expected %@ to equal %@", actual, expected);
}

- (void)testParseField {
  [self checkFields:@"(15)991231(3103)001750(10)12A"];
}

- (void)testParseField2 {
  [self checkFields:@"(15)991231(15)991231(3103)001750(10)12A"];
}

@end

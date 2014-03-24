/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXRSSExpandedFieldParser.h"
#import "ZXRSSExpandedFieldParserTest.h"

@implementation ZXRSSExpandedFieldParserTest

- (void)checkFields:(NSString *)expected {
  NSString *field = [[expected stringByReplacingOccurrencesOfString:@"(" withString:@""]
                     stringByReplacingOccurrencesOfString:@")" withString:@""];
  NSString *actual = [ZXRSSExpandedFieldParser parseFieldsInGeneralPurpose:field error:nil];
  XCTAssertEqualObjects(expected, actual);
}

- (void)testParseField {
  [self checkFields:@"(15)991231(3103)001750(10)12A"];
}

- (void)testParseField2 {
  [self checkFields:@"(15)991231(15)991231(3103)001750(10)12A"];
}

@end

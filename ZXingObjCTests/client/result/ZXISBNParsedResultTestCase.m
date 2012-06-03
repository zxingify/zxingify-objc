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
  ZXResult* fakeResult = [ZXResult resultWithText:contents rawBytes:NULL length:0 resultPoints:nil format:kBarcodeFormatEan13];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeISBN, @"Types don't match");
  ZXISBNParsedResult* isbnResult = (ZXISBNParsedResult*)result;
  STAssertEqualObjects(isbnResult.isbn, contents, @"Contents don't match");
}

@end

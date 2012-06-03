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

#import "ZXCalendarParsedResult.h"
#import "ZXCalendarParsedResultTestCase.h"
#import "ZXParsedResult.h"
#import "ZXResultParser.h"

@interface ZXCalendarParsedResultTestCase ()

- (void)doTestWithContents:(NSString*)contents
               description:(NSString*)description
                   summary:(NSString*)summary
                  location:(NSString*)location
                     start:(NSString*)start
                       end:(NSString*)end;

- (void)doTestWithContents:(NSString*)contents
               description:(NSString*)description
                   summary:(NSString*)summary
                  location:(NSString*)location
                     start:(NSString*)start
                       end:(NSString*)end
                  attendee:(NSString*)attendee
                  latitude:(double)latitude
                 longitude:(double)longitude;


- (void)assertEqualOrNAN:(double)expected actual:(double)actual;

@end

@implementation ZXCalendarParsedResultTestCase

static double EPSILON = 0.0000000001;

- (void)testStartEnd {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"DTEND:20080505T234555Z\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:nil
                     start:@"20080504T123456Z"
                       end:@"20080505T234555Z"];
}

- (void)testNoVCalendar {
  [self doTestWithContents:@"BEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"DTEND:20080505T234555Z\r\n"
                           @"END:VEVENT"
               description:nil
                   summary:nil
                  location:nil
                     start:@"20080504T123456Z"
                       end:@"20080505T234555Z"];
}

- (void)testStart {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:nil
                     start:@"20080504T123456Z"
                       end:nil];
}

- (void)testSummary {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"SUMMARY:foo\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:@"foo"
                  location:nil
                     start:@"20080504T123456Z"
                       end:nil];
}

- (void)testLocation {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"LOCATION:Miami\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:@"Miami"
                     start:@"20080504T123456Z"
                       end:nil];
}

- (void)testDescription {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"DESCRIPTION:This is a test\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:@"This is a test"
                   summary:nil
                  location:nil
                     start:@"20080504T123456Z"
                       end:nil];
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"DESCRIPTION:This is a test\r\n\t with a continuation\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:@"This is a test with a continuation"
                   summary:nil
                  location:nil
                     start:@"20080504T123456Z"
                       end:nil];
}

- (void)testGeo {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"GEO:-12.345;-45.678\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:nil
                     start:@"20080504T123456Z"
                       end:nil
                  attendee:nil
                  latitude:-12.345
                 longitude:-45.678];
}

- (void)testVEventEscapes {
  [self doTestWithContents:@"BEGIN:VEVENT\n"
                           @"CREATED:20111109T110351Z\n"
                           @"LAST-MODIFIED:20111109T170034Z\n"
                           @"DTSTAMP:20111109T170034Z\n"
                           @"UID:0f6d14ef-6cb7-4484-9080-61447ccdf9c2\n"
                           @"SUMMARY:Summary line\n"
                           @"CATEGORIES:Private\n"
                           @"DTSTART;TZID=Europe/Vienna:20111110T110000\n"
                           @"DTEND;TZID=Europe/Vienna:20111110T120000\n"
                           @"LOCATION:Location\\, with\\, escaped\\, commas\n"
                           @"DESCRIPTION:Meeting with a friend\\nlook at homepage first\\n\\n\n"
                           @"  \\n\n"
                           @"SEQUENCE:1\n"
                           @"X-MOZ-GENERATION:1\n"
                           @"END:VEVENT"
               description:@"Meeting with a friend\nlook at homepage first\n\n\n  \n"
                   summary:@"Summary line"
                  location:@"Location, with, escaped, commas"
                     start:@"20111110T110000"
                       end:@"20111110T120000"];
}

- (void)testAllDayValueDate {
  [self doTestWithContents:@"BEGIN:VEVENT\n"
                           @"DTSTART;VALUE=DATE:20111110\n"
                           @"DTEND;VALUE=DATE:20111110\n"
                           @"END:VEVENT"
               description:nil
                   summary:nil
                  location:nil
                     start:@"20111110"
                       end:@"20111110"];
}

- (void)doTestWithContents:(NSString*)contents
               description:(NSString*)description
                   summary:(NSString*)summary
                  location:(NSString*)location
                     start:(NSString*)start
                       end:(NSString*)end {
  [self doTestWithContents:contents
               description:description
                   summary:summary
                  location:location
                     start:start
                       end:end
                  attendee:nil
                  latitude:NAN
                 longitude:NAN];
}

- (void)doTestWithContents:(NSString*)contents
               description:(NSString*)description
                   summary:(NSString*)summary
                  location:(NSString*)location
                     start:(NSString*)start
                       end:(NSString*)end
                  attendee:(NSString*)attendee
                  latitude:(double)latitude
                 longitude:(double)longitude {
  ZXResult* fakeResult = [ZXResult resultWithText:contents rawBytes:NULL length:0 resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeCalendar, @"Types do not match");
  ZXCalendarParsedResult* calResult = (ZXCalendarParsedResult*)result;
  STAssertEqualObjects(calResult.description, description, @"Descriptions do not match");
  STAssertEqualObjects(calResult.summary, summary, @"Summaries do not match");
  STAssertEqualObjects(calResult.location, location, @"Locations do not match");
  STAssertEqualObjects(calResult.start, start, @"Starts do not match");
  STAssertEqualObjects(calResult.end, end, @"Ends do not match");
  STAssertEqualObjects(calResult.attendee, attendee, @"Attendees do not match");
}

- (void)assertEqualOrNAN:(double)expected actual:(double)actual {
  if (isnan(expected)) {
    STAssertTrue(isnan(actual), @"Expected %f to be NAN", actual);
  } else {
    STAssertEqualsWithAccuracy(actual, expected, EPSILON, @"Expected %f to equal %f", actual, expected);
  }
}

@end

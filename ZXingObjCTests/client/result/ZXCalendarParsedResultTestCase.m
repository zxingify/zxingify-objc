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

#import "ZXCalendarParsedResultTestCase.h"

@implementation ZXCalendarParsedResultTestCase

static double EPSILON = 0.0000000001;
static NSDateFormatter *DATE_TIME_FORMAT = nil;

+ (void)initialize {
  DATE_TIME_FORMAT = [[NSDateFormatter alloc] init];
  DATE_TIME_FORMAT.dateFormat = @"yyyyMMdd'T'HHmmss'Z'";
}

- (void)testStartEnd {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"DTEND:20080505T234555Z\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:nil
               startString:@"20080504T123456Z"
                 endString:@"20080505T234555Z"];
}

- (void)testNoVCalendar {
  [self doTestWithContents:@"BEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"DTEND:20080505T234555Z\r\n"
                           @"END:VEVENT"
               description:nil
                   summary:nil
                  location:nil
               startString:@"20080504T123456Z"
                 endString:@"20080505T234555Z"];
}

- (void)testStart {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:nil
               startString:@"20080504T123456Z"
                 endString:nil];
}

- (void)testDuration {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"DURATION:P1D\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:nil
               startString:@"20080504T123456Z"
                 endString:@"20080505T123456Z"];
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"DURATION:P1DT2H3M4S\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:nil
               startString:@"20080504T123456Z"
                 endString:@"20080505T143800Z"];
}

- (void)testSummary {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"SUMMARY:foo\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:@"foo"
                  location:nil
               startString:@"20080504T123456Z"
                 endString:nil];
}

- (void)testLocation {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"LOCATION:Miami\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:@"Miami"
               startString:@"20080504T123456Z"
                 endString:nil];
}

- (void)testDescription {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"DESCRIPTION:This is a test\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:@"This is a test"
                   summary:nil
                  location:nil
               startString:@"20080504T123456Z"
                 endString:nil];
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"DESCRIPTION:This is a test\r\n\t with a continuation\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:@"This is a test with a continuation"
                   summary:nil
                  location:nil
               startString:@"20080504T123456Z"
                 endString:nil];
}

- (void)testGeo {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"GEO:-12.345;-45.678\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:nil
               startString:@"20080504T123456Z"
                 endString:nil
                 organizer:nil
                  attendees:nil
                  latitude:-12.345
                 longitude:-45.678];
}

- (void)testOrganizer {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"ORGANIZER:mailto:bob@example.org\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:nil
               startString:@"20080504T123456Z"
                 endString:nil
                 organizer:@"bob@example.org"
                 attendees:nil
                  latitude:NAN
                 longitude:NAN];
}

- (void)testAttendees {
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"ATTENDEE:mailto:bob@example.org\r\n"
                           @"ATTENDEE:mailto:alice@example.org\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:nil
                   summary:nil
                  location:nil
               startString:@"20080504T123456Z"
                 endString:nil
                 organizer:nil
                 attendees:@[@"bob@example.org", @"alice@example.org"]
                  latitude:NAN
                 longitude:NAN];
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
               startString:@"20111110T110000Z"
                 endString:@"20111110T120000Z"];
}

- (void)testAllDayValueDate {
  [self doTestWithContents:@"BEGIN:VEVENT\n"
                           @"DTSTART;VALUE=DATE:20111110\n"
                           @"DTEND;VALUE=DATE:20111110\n"
                           @"END:VEVENT"
               description:nil
                   summary:nil
                  location:nil
               startString:@"20111110T000000Z"
                 endString:@"20111110T000000Z"];
}

- (void)doTestWithContents:(NSString *)contents
               description:(NSString *)description
                   summary:(NSString *)summary
                  location:(NSString *)location
               startString:(NSString *)startString
                 endString:(NSString *)endString {
  [self doTestWithContents:contents
               description:description
                   summary:summary
                  location:location
               startString:startString
                 endString:endString
                 organizer:nil
                 attendees:nil
                  latitude:NAN
                 longitude:NAN];
}

- (void)doTestWithContents:(NSString *)contents
               description:(NSString *)description
                   summary:(NSString *)summary
                  location:(NSString *)location
               startString:(NSString *)startString
                 endString:(NSString *)endString
                 organizer:(NSString *)organizer
                 attendees:(NSArray *)attendees
                  latitude:(double)latitude
                 longitude:(double)longitude {
  ZXResult *fakeResult = [ZXResult resultWithText:contents rawBytes:nil resultPoints:nil format:kBarcodeFormatQRCode];
  ZXParsedResult *result = [ZXResultParser parseResult:fakeResult];
  XCTAssertEqual(result.type, kParsedResultTypeCalendar, @"Types do not match");
  ZXCalendarParsedResult *calResult = (ZXCalendarParsedResult *)result;
  XCTAssertEqualObjects(calResult.description, description, @"Descriptions do not match");
  XCTAssertEqualObjects(calResult.summary, summary, @"Summaries do not match");
  XCTAssertEqualObjects(calResult.location, location, @"Locations do not match");
  XCTAssertEqualObjects([DATE_TIME_FORMAT stringFromDate:calResult.start], startString, @"Starts do not match");
  XCTAssertEqualObjects([DATE_TIME_FORMAT stringFromDate:calResult.end], endString, @"Ends do not match");
  XCTAssertEqualObjects(organizer, calResult.organizer, @"Organizers do not match");
  XCTAssertEqualObjects(attendees, calResult.attendees, @"Attendees do not match");
  [self assertEqualOrNAN:latitude actual:calResult.latitude];
  [self assertEqualOrNAN:longitude actual:calResult.longitude];
}

- (void)assertEqualOrNAN:(double)expected actual:(double)actual {
  if (isnan(expected)) {
    XCTAssertTrue(isnan(actual), @"Expected %f to be NAN", actual);
  } else {
    XCTAssertEqualWithAccuracy(actual, expected, EPSILON, @"Expected %f to equal %f", actual, expected);
  }
}

@end

#import "CalendarParsedResultTestCase.h"
#import "ZXCalendarParsedResult.h"
#import "ZXParsedResult.h"
#import "ZXResultParser.h"

@interface CalendarParsedResultTestCase ()

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

@implementation CalendarParsedResultTestCase

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
                       end:@"20080504T123456Z"];
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
                       end:@"20080504T123456Z"];
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
                       end:@"20080504T123456Z"];
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
                       end:@"20080504T123456Z"];
  [self doTestWithContents:@"BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n"
                           @"DTSTART:20080504T123456Z\r\n"
                           @"DESCRIPTION:This is a test\r\n\t with a continuation\r\n"
                           @"END:VEVENT\r\nEND:VCALENDAR"
               description:@"This is a test with a continuation"
                   summary:nil
                  location:nil
                     start:@"20080504T123456Z"
                       end:@"20080504T123456Z"];
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
                       end:@"20080504T123456Z"
                  attendee:nil
                  latitude:-12.345
                 longitude:-45.678];
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
  ZXResult* fakeResult = [[[ZXResult alloc] initWithText:contents
                                                rawBytes:NULL
                                                  length:0
                                            resultPoints:nil
                                                  format:kBarcodeFormatQRCode] autorelease];
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

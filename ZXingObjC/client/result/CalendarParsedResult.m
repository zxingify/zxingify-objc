#import "CalendarParsedResult.h"

@implementation CalendarParsedResult

@synthesize summary;
@synthesize start;
@synthesize end;
@synthesize location;
@synthesize attendee;
@synthesize description;
@synthesize latitude;
@synthesize longitude;
@synthesize displayResult;

- (id) init:(NSString *)summary start:(NSString *)start end:(NSString *)end location:(NSString *)location attendee:(NSString *)attendee description:(NSString *)description {
  if (self = [self init:summary start:start end:end location:location attendee:attendee description:description latitude:Double.NaN longitude:Double.NaN]) {
  }
  return self;
}

- (id) init:(NSString *)summary start:(NSString *)start end:(NSString *)end location:(NSString *)location attendee:(NSString *)attendee description:(NSString *)description latitude:(double)latitude longitude:(double)longitude {
  if (self = [super init:ParsedResultType.CALENDAR]) {
    if (start == nil) {
      @throw [[[IllegalArgumentException alloc] init] autorelease];
    }
    [self validateDate:start];
    if (end == nil) {
      end = start;
    }
     else {
      [self validateDate:end];
    }
    summary = summary;
    start = start;
    end = end;
    location = location;
    attendee = attendee;
    description = description;
    latitude = latitude;
    longitude = longitude;
  }
  return self;
}

- (NSString *) displayResult {
  NSMutableString * result = [[[NSMutableString alloc] init:100] autorelease];
  [self maybeAppend:summary param1:result];
  [self maybeAppend:start param1:result];
  [self maybeAppend:end param1:result];
  [self maybeAppend:location param1:result];
  [self maybeAppend:attendee param1:result];
  [self maybeAppend:description param1:result];
  return [result description];
}


/**
 * RFC 2445 allows the start and end fields to be of type DATE (e.g. 20081021) or DATE-TIME
 * (e.g. 20081021T123000 for local time, or 20081021T123000Z for UTC).
 * 
 * @param date The string to validate
 */
+ (void) validateDate:(NSString *)date {
  if (date != nil) {
    int length = [date length];
    if (length != 8 && length != 15 && length != 16) {
      @throw [[[IllegalArgumentException alloc] init] autorelease];
    }

    for (int i = 0; i < 8; i++) {
      if (![Character isDigit:[date characterAtIndex:i]]) {
        @throw [[[IllegalArgumentException alloc] init] autorelease];
      }
    }

    if (length > 8) {
      if ([date characterAtIndex:8] != 'T') {
        @throw [[[IllegalArgumentException alloc] init] autorelease];
      }

      for (int i = 9; i < 15; i++) {
        if (![Character isDigit:[date characterAtIndex:i]]) {
          @throw [[[IllegalArgumentException alloc] init] autorelease];
        }
      }

      if (length == 16 && [date characterAtIndex:15] != 'Z') {
        @throw [[[IllegalArgumentException alloc] init] autorelease];
      }
    }
  }
}

- (void) dealloc {
  [summary release];
  [start release];
  [end release];
  [location release];
  [attendee release];
  [description release];
  [super dealloc];
}

@end

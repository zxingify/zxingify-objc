#import "CalendarParsedResult.h"

@interface CalendarParsedResult ()

- (void) validateDate:(NSString *)date;

@end

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

- (id) initWithSummary:(NSString *)aSummary start:(NSString *)aStart end:(NSString *)anEnd location:(NSString *)aLocation attendee:(NSString *)anAttendee description:(NSString *)aDescription latitude:(double)aLatitude longitude:(double)aLongitude {
  if (self = [super initWithType:kParsedResultTypeCalendar]) {
    if (aStart == nil) {
      [NSException raise:NSInvalidArgumentException 
                  format:@"Start is required"];
    }
    [self validateDate:aStart];
    if (anEnd == nil) {
      anEnd = aStart;
    } else {
      [self validateDate:anEnd];
    }
    summary = [aSummary copy];
    start = [aStart copy];
    end = [anEnd copy];
    location = [aLocation copy];
    attendee = [anAttendee copy];
    description = [aDescription copy];
    latitude = aLatitude;
    longitude = aLongitude;
  }
  return self;
}

- (NSString *) displayResult {
  NSMutableString * result = [NSMutableString stringWithCapacity:100];
  [ParsedResult maybeAppend:summary result:result];
  [ParsedResult maybeAppend:start result:result];
  [ParsedResult maybeAppend:end result:result];
  [ParsedResult maybeAppend:location result:result];
  [ParsedResult maybeAppend:attendee result:result];
  [ParsedResult maybeAppend:description result:result];
  return result;
}


/**
 * RFC 2445 allows the start and end fields to be of type DATE (e.g. 20081021) or DATE-TIME
 * (e.g. 20081021T123000 for local time, or 20081021T123000Z for UTC).
 * 
 * @param date The string to validate
 */
- (void) validateDate:(NSString *)date {
  if (date != nil) {
    int length = [date length];
    if (length != 8 && length != 15 && length != 16) {
      [NSException raise:NSInvalidArgumentException 
                  format:@"Invalid length"];
    }

    for (int i = 0; i < 8; i++) {
      if (!isdigit([date characterAtIndex:i])) {
        [NSException raise:NSInvalidArgumentException 
                    format:@"Invalid date"];
      }
    }

    if (length > 8) {
      if ([date characterAtIndex:8] != 'T') {
        [NSException raise:NSInvalidArgumentException 
                    format:@"Invalid date"];
      }

      for (int i = 9; i < 15; i++) {
        if (!isdigit([date characterAtIndex:i])) {
          [NSException raise:NSInvalidArgumentException 
                      format:@"Invalid date"];
        }
      }

      if (length == 16 && [date characterAtIndex:15] != 'Z') {
        [NSException raise:NSInvalidArgumentException 
                    format:@"Invalid date"];
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

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

@interface ZXCalendarParsedResult ()

@property(nonatomic, retain) NSString * summary;
@property(nonatomic, retain) NSString * start;
@property(nonatomic, retain) NSString * end;
@property(nonatomic, retain) NSString * location;
@property(nonatomic, retain) NSString * attendee;
@property(nonatomic, retain) NSString * description;
@property(nonatomic) double latitude;
@property(nonatomic) double longitude;

- (void)validateDate:(NSString *)date;

@end

@implementation ZXCalendarParsedResult

@synthesize summary;
@synthesize start;
@synthesize end;
@synthesize location;
@synthesize attendee;
@synthesize description;
@synthesize latitude;
@synthesize longitude;

- (id)initWithSummary:(NSString *)aSummary start:(NSString *)aStart end:(NSString *)anEnd location:(NSString *)aLocation
             attendee:(NSString *)anAttendee description:(NSString *)aDescription latitude:(double)aLatitude longitude:(double)aLongitude {
  if (self = [super initWithType:kParsedResultTypeCalendar]) {
    [self validateDate:aStart];
    self.summary = aSummary;
    self.start = aStart;
    if (anEnd != nil) {
      [self validateDate:end];
      self.end = anEnd;
    } else {
      self.end = nil;
    }
    self.location = aLocation;
    self.attendee = anAttendee;
    self.description = aDescription;
    self.latitude = aLatitude;
    self.longitude = aLongitude;
  }
  return self;
}

+ (id)calendarParsedResultWithSummary:(NSString *)summary start:(NSString *)start end:(NSString *)end location:(NSString *)location
                             attendee:(NSString *)attendee description:(NSString *)description latitude:(double)latitude longitude:(double)longitude {
  return [[[self alloc] initWithSummary:summary start:start end:end location:location attendee:attendee
                            description:description latitude:latitude longitude:longitude] autorelease];
}

- (void)dealloc {
  [summary release];
  [start release];
  [end release];
  [location release];
  [attendee release];
  [description release];
  [super dealloc];
}

- (NSString *)displayResult {
  NSMutableString * result = [NSMutableString stringWithCapacity:100];
  [ZXParsedResult maybeAppend:self.summary result:result];
  [ZXParsedResult maybeAppend:self.start result:result];
  [ZXParsedResult maybeAppend:self.end result:result];
  [ZXParsedResult maybeAppend:self.location result:result];
  [ZXParsedResult maybeAppend:self.attendee result:result];
  [ZXParsedResult maybeAppend:self.description result:result];
  return result;
}


/**
 * RFC 2445 allows the start and end fields to be of type DATE (e.g. 20081021) or DATE-TIME
 * (e.g. 20081021T123000 for local time, or 20081021T123000Z for UTC).
 * 
 * @param date The string to validate
 */
- (void)validateDate:(NSString *)date {
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

@end

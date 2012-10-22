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
#import "ZXResult.h"
#import "ZXVCardResultParser.h"
#import "ZXVEventResultParser.h"

@interface ZXVEventResultParser ()

- (NSString*)matchSingleVCardPrefixedField:(NSString*)prefix rawText:(NSString *)rawText trim:(BOOL)trim;

@end

@implementation ZXVEventResultParser

- (ZXParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = [ZXResultParser massagedText:result];
  if (rawText == nil) {
    return nil;
  }
  int vEventStart = [rawText rangeOfString:@"BEGIN:VEVENT"].location;
  if (vEventStart == NSNotFound) {
    return nil;
  }

  NSString * summary = [self matchSingleVCardPrefixedField:@"SUMMARY" rawText:rawText trim:YES];
  NSString * start = [self matchSingleVCardPrefixedField:@"DTSTART" rawText:rawText trim:YES];
  if (start == nil) {
    return nil;
  }
  NSString * end = [self matchSingleVCardPrefixedField:@"DTEND" rawText:rawText trim:YES];
  NSString * location = [self matchSingleVCardPrefixedField:@"LOCATION" rawText:rawText trim:YES];
  NSString * description = [self matchSingleVCardPrefixedField:@"DESCRIPTION" rawText:rawText trim:YES];

  NSString * geoString = [self matchSingleVCardPrefixedField:@"GEO" rawText:rawText trim:YES];
  double latitude;
  double longitude;
  if (geoString == nil) {
    latitude = NAN;
    longitude = NAN;
  } else {
    int semicolon = [geoString rangeOfString:@";"].location;
    latitude = [[geoString substringToIndex:semicolon] doubleValue];
    longitude = [[geoString substringFromIndex:semicolon + 1] doubleValue];
  }

  @try {
    return [ZXCalendarParsedResult calendarParsedResultWithSummary:summary
                                                             start:start
                                                               end:end
                                                          location:location
                                                          attendee:nil
                                                       description:description
                                                          latitude:latitude
                                                         longitude:longitude];
  } @catch (NSException * iae) {
    return nil;
  }
}

- (NSString*)matchSingleVCardPrefixedField:(NSString*)prefix rawText:(NSString *)rawText trim:(BOOL)trim {
  NSArray * values = [ZXVCardResultParser matchSingleVCardPrefixedField:prefix rawText:rawText trim:trim parseFieldDivider:NO];
  return values == nil || values.count == 0 ? nil : [values objectAtIndex:0];
}

@end

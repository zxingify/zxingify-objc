#import "CalendarParsedResult.h"
#import "Result.h"
#import "VCardResultParser.h"
#import "VEventResultParser.h"

@implementation VEventResultParser

+ (CalendarParsedResult *) parse:(Result *)result {
  NSString * rawText = result.text;
  if (rawText == nil) {
    return nil;
  }
  int vEventStart = [rawText rangeOfString:@"BEGIN:VEVENT"].location;
  if (vEventStart < 0) {
    return nil;
  }

  NSString * summary = [VCardResultParser matchSingleVCardPrefixedField:@"SUMMARY" rawText:rawText trim:YES];
  NSString * start = [VCardResultParser matchSingleVCardPrefixedField:@"DTSTART" rawText:rawText trim:YES];
  NSString * end = [VCardResultParser matchSingleVCardPrefixedField:@"DTEND" rawText:rawText trim:YES];
  NSString * location = [VCardResultParser matchSingleVCardPrefixedField:@"LOCATION" rawText:rawText trim:YES];
  NSString * description = [VCardResultParser matchSingleVCardPrefixedField:@"DESCRIPTION" rawText:rawText trim:YES];

  NSString * geoString = [VCardResultParser matchSingleVCardPrefixedField:@"GEO" rawText:rawText trim:YES];
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
    return [[[CalendarParsedResult alloc] initWithSummary:summary
                                                    start:start
                                                      end:end
                                                 location:location
                                                 attendee:nil
                                              description:description
                                                 latitude:latitude
                                                longitude:longitude] autorelease];
  }
  @catch (NSException * iae) {
    return nil;
  }
}

@end

#import "ZXCalendarParsedResult.h"
#import "ZXResult.h"
#import "ZXVCardResultParser.h"
#import "ZXVEventResultParser.h"

@implementation ZXVEventResultParser

+ (ZXCalendarParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = result.text;
  if (rawText == nil) {
    return nil;
  }
  int vEventStart = [rawText rangeOfString:@"BEGIN:VEVENT"].location;
  if (vEventStart == NSNotFound) {
    return nil;
  }

  NSString * summary = [ZXVCardResultParser matchSingleVCardPrefixedField:@"SUMMARY" rawText:rawText trim:YES];
  NSString * start = [ZXVCardResultParser matchSingleVCardPrefixedField:@"DTSTART" rawText:rawText trim:YES];
  NSString * end = [ZXVCardResultParser matchSingleVCardPrefixedField:@"DTEND" rawText:rawText trim:YES];
  NSString * location = [ZXVCardResultParser matchSingleVCardPrefixedField:@"LOCATION" rawText:rawText trim:YES];
  NSString * description = [ZXVCardResultParser matchSingleVCardPrefixedField:@"DESCRIPTION" rawText:rawText trim:YES];

  NSString * geoString = [ZXVCardResultParser matchSingleVCardPrefixedField:@"GEO" rawText:rawText trim:YES];
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
    return [[[ZXCalendarParsedResult alloc] initWithSummary:summary
                                                      start:start
                                                        end:end
                                                   location:location
                                                   attendee:nil
                                                description:description
                                                   latitude:latitude
                                                  longitude:longitude] autorelease];
  } @catch (NSException * iae) {
    return nil;
  }
}

@end

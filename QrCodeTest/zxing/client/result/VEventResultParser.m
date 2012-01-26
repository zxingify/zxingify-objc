#import "VEventResultParser.h"

@implementation VEventResultParser

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (CalendarParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil) {
    return nil;
  }
  int vEventStart = [rawText rangeOfString:@"BEGIN:VEVENT"];
  if (vEventStart < 0) {
    return nil;
  }
  NSString * summary = [VCardResultParser matchSingleVCardPrefixedField:@"SUMMARY" param1:rawText param2:YES];
  NSString * start = [VCardResultParser matchSingleVCardPrefixedField:@"DTSTART" param1:rawText param2:YES];
  NSString * end = [VCardResultParser matchSingleVCardPrefixedField:@"DTEND" param1:rawText param2:YES];
  NSString * location = [VCardResultParser matchSingleVCardPrefixedField:@"LOCATION" param1:rawText param2:YES];
  NSString * description = [VCardResultParser matchSingleVCardPrefixedField:@"DESCRIPTION" param1:rawText param2:YES];
  NSString * geoString = [VCardResultParser matchSingleVCardPrefixedField:@"GEO" param1:rawText param2:YES];
  double latitude;
  double longitude;
  if (geoString == nil) {
    latitude = Double.NaN;
    longitude = Double.NaN;
  }
   else {
    int semicolon = [geoString rangeOfString:';'];

    @try {
      latitude = [Double parseDouble:[geoString substringFromIndex:0 param1:semicolon]];
      longitude = [Double parseDouble:[geoString substringFromIndex:semicolon + 1]];
    }
    @catch (NumberFormatException * nfe) {
      return nil;
    }
  }

  @try {
    return [[[CalendarParsedResult alloc] init:summary param1:start param2:end param3:location param4:nil param5:description param6:latitude param7:longitude] autorelease];
  }
  @catch (IllegalArgumentException * iae) {
    return nil;
  }
}

@end

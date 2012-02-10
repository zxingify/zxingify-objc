#import "GeoParsedResult.h"
#import "GeoResultParser.h"

@implementation GeoResultParser

+ (GeoParsedResult *) parse:(Result *)result {
  NSString * rawText = [result text];
  if (rawText == nil || (![rawText hasPrefix:@"geo:"] && ![rawText hasPrefix:@"GEO:"])) {
    return nil;
  }
  int queryStart = [rawText rangeOfString:'?' param1:4];
  NSString * query;
  NSString * geoURIWithoutQuery;
  if (queryStart < 0) {
    query = nil;
    geoURIWithoutQuery = [rawText substringFromIndex:4];
  }
   else {
    query = [rawText substringFromIndex:queryStart + 1];
    geoURIWithoutQuery = [rawText substringFromIndex:4 param1:queryStart];
  }
  int latitudeEnd = [geoURIWithoutQuery rangeOfString:','];
  if (latitudeEnd < 0) {
    return nil;
  }
  int longitudeEnd = [geoURIWithoutQuery rangeOfString:',' param1:latitudeEnd + 1];
  double latitude;
  double longitude;
  double altitude;

  @try {
    latitude = [Double parseDouble:[geoURIWithoutQuery substringFromIndex:0 param1:latitudeEnd]];
    if (latitude > 90.0 || latitude < -90.0) {
      return nil;
    }
    if (longitudeEnd < 0) {
      longitude = [Double parseDouble:[geoURIWithoutQuery substringFromIndex:latitudeEnd + 1]];
      altitude = 0.0;
    }
     else {
      longitude = [Double parseDouble:[geoURIWithoutQuery substringFromIndex:latitudeEnd + 1 param1:longitudeEnd]];
      altitude = [Double parseDouble:[geoURIWithoutQuery substringFromIndex:longitudeEnd + 1]];
    }
    if (longitude > 180.0 || longitude < -180.0 || altitude < 0) {
      return nil;
    }
  }
  @catch (NumberFormatException * nfe) {
    return nil;
  }
  return [[[GeoParsedResult alloc] init:latitude param1:longitude param2:altitude param3:query] autorelease];
}

@end

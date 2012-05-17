#import "ZXGeoParsedResult.h"
#import "ZXGeoResultParser.h"

@implementation ZXGeoResultParser

+ (ZXGeoParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = [result text];
  if (rawText == nil || (![rawText hasPrefix:@"geo:"] && ![rawText hasPrefix:@"GEO:"])) {
    return nil;
  }
  int queryStart = [rawText rangeOfString:@"?" options:NSLiteralSearch range:NSMakeRange(4, [rawText length] - 4)].location;
  NSString * query;
  NSString * geoURIWithoutQuery;
  if (queryStart == NSNotFound) {
    query = nil;
    geoURIWithoutQuery = [rawText substringFromIndex:4];
  } else {
    query = [rawText substringFromIndex:queryStart + 1];
    geoURIWithoutQuery = [rawText substringWithRange:NSMakeRange(4, queryStart + 4)];
  }
  int latitudeEnd = [geoURIWithoutQuery rangeOfString:@","].location;
  if (latitudeEnd == NSNotFound) {
    return nil;
  }
  int longitudeEnd = [geoURIWithoutQuery rangeOfString:@"," options:NSLiteralSearch range:NSMakeRange(latitudeEnd + 1, [geoURIWithoutQuery length] - latitudeEnd + 1)].location;
  double latitude;
  double longitude;
  double altitude;

  latitude = [[geoURIWithoutQuery substringToIndex:latitudeEnd] doubleValue];
  if (latitude > 90.0 || latitude < -90.0) {
    return nil;
  }
  if (longitudeEnd == NSNotFound) {
    longitude = [[geoURIWithoutQuery substringFromIndex:latitudeEnd + 1] doubleValue];
    altitude = 0.0;
  } else {
    longitude = [[geoURIWithoutQuery substringWithRange:NSMakeRange(latitudeEnd + 1, [geoURIWithoutQuery length] - longitudeEnd)] doubleValue];
    altitude = [[geoURIWithoutQuery substringFromIndex:longitudeEnd + 1] doubleValue];
  }
  if (longitude > 180.0 || longitude < -180.0 || altitude < 0) {
    return nil;
  }

  return [[[ZXGeoParsedResult alloc] initWithLatitude:latitude longitude:longitude altitude:altitude query:query] autorelease];
}

@end

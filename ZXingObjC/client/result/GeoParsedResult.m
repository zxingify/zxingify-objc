#import "GeoParsedResult.h"
#import "ParsedResultType.h"

@implementation GeoParsedResult

@synthesize latitude;
@synthesize longitude;
@synthesize altitude;
@synthesize query;
@synthesize displayResult;

- (id) initWithLatitude:(double)aLatitude longitude:(double)aLongitude altitude:(double)anAltitude query:(NSString *)aQuery {
  if (self = [super initWithType:kParsedResultTypeGeo]) {
    self.latitude = aLatitude;
    self.longitude = aLongitude;
    self.altitude = anAltitude;
    self.query = aQuery;
  }
  return self;
}

- (NSString *) geoURI {
  NSMutableString *result = [NSMutableString string];
  [result appendFormat:@"geo:%f,%f", self.latitude, self.longitude];
  if (self.altitude > 0) {
    [result appendFormat:@",%f", self.altitude];
  }
  if (self.query != nil) {
    [result appendFormat:@"?%@", query];
  }
  return result;
}

- (NSString *) displayResult {
  NSMutableString *result = [NSMutableString string];
  [result appendFormat:@"%f, %f", self.latitude, self.longitude];
  if (self.altitude > 0.0) {
    [result appendFormat:@", %f", self.altitude];
    [result appendString:@"m"];
  }
  if (self.query != nil) {
    [result appendFormat:@" (%@)", self.query];
  }
  return result;
}

- (void) dealloc {
  [query release];
  [super dealloc];
}

@end

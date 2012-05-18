#import "ZXGeoParsedResult.h"
#import "ZXParsedResultType.h"

@interface ZXGeoParsedResult ()

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double altitude;
@property (nonatomic, copy) NSString * query;

@end

@implementation ZXGeoParsedResult

@synthesize latitude;
@synthesize longitude;
@synthesize altitude;
@synthesize query;

- (id)initWithLatitude:(double)aLatitude longitude:(double)aLongitude altitude:(double)anAltitude query:(NSString *)aQuery {
  if (self = [super initWithType:kParsedResultTypeGeo]) {
    self.latitude = aLatitude;
    self.longitude = aLongitude;
    self.altitude = anAltitude;
    self.query = aQuery;
  }

  return self;
}

- (void) dealloc {
  [query release];

  [super dealloc];
}

- (NSString *)geoURI {
  NSMutableString *result = [NSMutableString string];
  [result appendFormat:@"geo:%f,%f", self.latitude, self.longitude];
  if (self.altitude > 0) {
    [result appendFormat:@",%f", self.altitude];
  }
  if (self.query != nil) {
    [result appendFormat:@"?%@", query];
  }
  return [NSString stringWithString:result];
}

- (NSString *)displayResult {
  NSMutableString *result = [NSMutableString string];
  [result appendFormat:@"%f, %f", self.latitude, self.longitude];
  if (self.altitude > 0.0) {
    [result appendFormat:@", %f", self.altitude];
    [result appendString:@"m"];
  }
  if (self.query != nil) {
    [result appendFormat:@" (%@)", self.query];
  }
  return [NSString stringWithString:result];
}

@end

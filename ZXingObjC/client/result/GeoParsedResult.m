#import "GeoParsedResult.h"

@implementation GeoParsedResult

@synthesize geoURI;
@synthesize latitude;
@synthesize longitude;
@synthesize altitude;
@synthesize query;
@synthesize displayResult;

- (id) init:(double)latitude longitude:(double)longitude altitude:(double)altitude query:(NSString *)query {
  if (self = [super init:ParsedResultType.GEO]) {
    latitude = latitude;
    longitude = longitude;
    altitude = altitude;
    query = query;
  }
  return self;
}

- (NSString *) geoURI {
  StringBuffer * result = [[[StringBuffer alloc] init] autorelease];
  [result append:@"geo:"];
  [result append:latitude];
  [result append:','];
  [result append:longitude];
  if (altitude > 0) {
    [result append:','];
    [result append:altitude];
  }
  if (query != nil) {
    [result append:'?'];
    [result append:query];
  }
  return [result description];
}

- (NSString *) displayResult {
  StringBuffer * result = [[[StringBuffer alloc] init:20] autorelease];
  [result append:latitude];
  [result append:@", "];
  [result append:longitude];
  if (altitude > 0.0) {
    [result append:@", "];
    [result append:altitude];
    [result append:'m'];
  }
  if (query != nil) {
    [result append:@" ("];
    [result append:query];
    [result append:')'];
  }
  return [result description];
}

- (void) dealloc {
  [query release];
  [super dealloc];
}

@end

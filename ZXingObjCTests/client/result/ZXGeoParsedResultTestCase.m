#import "ZXGeoParsedResult.h"
#import "ZXGeoParsedResultTestCase.h"
#import "ZXResultParser.h"

@interface ZXGeoParsedResultTestCase ()

- (void)doTestWithContents:(NSString*)contents
                  latitude:(double)latitude
                 longitude:(double)longitude
                  altitude:(double)altitude
                     query:(NSString*)query;

@end

@implementation ZXGeoParsedResultTestCase

static double EPSILON = 0.0000000001;

- (void)testGeo {
  [self doTestWithContents:@"geo:1,2" latitude:1.0 longitude:2.0 altitude:0.0 query:nil];
  [self doTestWithContents:@"geo:80.33,-32.3344,3.35" latitude:80.33 longitude:-32.3344 altitude:3.35 query:nil];
  [self doTestWithContents:@"geo:-20.33,132.3344,0.01" latitude:-20.33 longitude:132.3344 altitude:0.01 query:nil];
  [self doTestWithContents:@"geo:-20.33,132.3344,0.01?q=foobar" latitude:-20.33 longitude:132.3344 altitude:0.01 query:@"q=foobar"];
}

- (void)doTestWithContents:(NSString*)contents
                  latitude:(double)latitude
                 longitude:(double)longitude
                  altitude:(double)altitude
                     query:(NSString*)query {
  ZXResult* fakeResult = [[[ZXResult alloc] initWithText:contents rawBytes:NULL length:0 resultPoints:nil format:kBarcodeFormatQRCode] autorelease];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeGeo, @"Types don't match");
  ZXGeoParsedResult* geoResult = (ZXGeoParsedResult*)result;
  STAssertEqualsWithAccuracy(geoResult.latitude, latitude, EPSILON, @"Latitudes don't match");
  STAssertEqualsWithAccuracy(geoResult.longitude, longitude, EPSILON, @"Longitudes don't match");
  STAssertEqualsWithAccuracy(geoResult.altitude, altitude, EPSILON, @"Altitudes don't match");
  STAssertEqualObjects(geoResult.query, query, @"Queries don't match");
}

@end

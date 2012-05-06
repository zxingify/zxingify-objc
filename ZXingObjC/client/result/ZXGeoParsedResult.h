#import "ZXParsedResult.h"

@interface ZXGeoParsedResult : ZXParsedResult

@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;
@property (nonatomic, readonly) double altitude;
@property (nonatomic, copy, readonly) NSString * query;

- (id)initWithLatitude:(double)latitude longitude:(double)longitude altitude:(double)altitude query:(NSString *)query;
- (NSString *)geoURI;

@end

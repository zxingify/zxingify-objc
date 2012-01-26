
/**
 * @author Sean Owen
 */

@interface GeoParsedResult : ParsedResult {
  double latitude;
  double longitude;
  double altitude;
  NSString * query;
}

@property(nonatomic, retain, readonly) NSString * geoURI;
@property(nonatomic, readonly) double latitude;
@property(nonatomic, readonly) double longitude;
@property(nonatomic, readonly) double altitude;
@property(nonatomic, retain, readonly) NSString * query;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) init:(double)latitude longitude:(double)longitude altitude:(double)altitude query:(NSString *)query;
@end

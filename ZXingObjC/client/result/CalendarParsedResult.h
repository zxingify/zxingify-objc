#import "ParsedResult.h"

/**
 * @author Sean Owen
 */

@interface CalendarParsedResult : ParsedResult {
  NSString * summary;
  NSString * start;
  NSString * end;
  NSString * location;
  NSString * attendee;
  NSString * description;
  double latitude;
  double longitude;
}

@property(nonatomic, retain, readonly) NSString * summary;
@property(nonatomic, retain, readonly) NSString * start;
@property(nonatomic, retain, readonly) NSString * end;
@property(nonatomic, retain, readonly) NSString * location;
@property(nonatomic, retain, readonly) NSString * attendee;
@property(nonatomic, retain, readonly) NSString * description;
@property(nonatomic, readonly) double latitude;
@property(nonatomic, readonly) double longitude;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) init:(NSString *)summary start:(NSString *)start end:(NSString *)end location:(NSString *)location attendee:(NSString *)attendee description:(NSString *)description;
- (id) init:(NSString *)summary start:(NSString *)start end:(NSString *)end location:(NSString *)location attendee:(NSString *)attendee description:(NSString *)description latitude:(double)latitude longitude:(double)longitude;
@end

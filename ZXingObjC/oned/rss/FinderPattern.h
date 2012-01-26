#import "ResultPoint.h"

@interface FinderPattern : NSObject {
  int value;
  NSArray * startEnd;
  NSArray * resultPoints;
}

@property(nonatomic, readonly) int value;
@property(nonatomic, retain, readonly) NSArray * startEnd;
@property(nonatomic, retain, readonly) NSArray * resultPoints;
- (id) init:(int)value startEnd:(NSArray *)startEnd start:(int)start end:(int)end rowNumber:(int)rowNumber;
@end

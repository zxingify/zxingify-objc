#import "ResultPoint.h"

@interface RSSFinderPattern : NSObject {
  int value;
  NSArray * startEnd;
  NSArray * resultPoints;
}

@property(nonatomic, assign) int value;
@property(nonatomic, retain) NSArray * startEnd;
@property(nonatomic, retain) NSArray * resultPoints;

- (id) initWithValue:(int)value startEnd:(NSArray *)startEnd start:(int)start end:(int)end rowNumber:(int)rowNumber;

@end

#import "ZXResultPoint.h"

@interface ZXRSSFinderPattern : NSObject

@property (nonatomic, assign, readonly) int value;
@property (nonatomic, retain, readonly) NSArray * startEnd;
@property (nonatomic, retain, readonly) NSArray * resultPoints;

- (id)initWithValue:(int)value startEnd:(NSArray *)startEnd start:(int)start end:(int)end rowNumber:(int)rowNumber;

@end

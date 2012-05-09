#import "ZXDecodedObject.h"

@interface ZXDecodedInformation : ZXDecodedObject

@property (nonatomic, copy, readonly) NSString * theNewString;
@property (nonatomic, assign, readonly) int remainingValue;
@property (nonatomic, assign, readonly) BOOL remaining;

- (id)initWithNewPosition:(int)newPosition newString:(NSString *)newString;
- (id)initWithNewPosition:(int)newPosition newString:(NSString *)newString remainingValue:(int)remainingValue;

@end

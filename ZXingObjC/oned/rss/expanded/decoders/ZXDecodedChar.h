#import "ZXDecodedObject.h"

extern unichar const FNC1char;

@interface ZXDecodedChar : ZXDecodedObject

@property (nonatomic, assign, readonly) unichar value;

- (id)initWithNewPosition:(int)newPosition value:(unichar)value;
- (BOOL)fnc1;

@end

#import "ZXDecodedObject.h"

extern const int FNC1;

@interface ZXDecodedNumeric : ZXDecodedObject

@property (nonatomic, assign, readonly) int firstDigit;
@property (nonatomic, assign, readonly) int secondDigit;
@property (nonatomic, assign, readonly) int value;

- (id)initWithNewPosition:(int)newPosition firstDigit:(int)firstDigit secondDigit:(int)secondDigit;
- (BOOL)firstDigitFNC1;
- (BOOL)secondDigitFNC1;
- (BOOL)anyFNC1;

@end

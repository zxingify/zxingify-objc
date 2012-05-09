#import "ZXDataCharacter.h"

@class ZXRSSFinderPattern;

@interface ZXPair : ZXDataCharacter

@property (nonatomic, assign, readonly) int count;
@property (nonatomic, retain, readonly) ZXRSSFinderPattern * finderPattern;

- (id)initWithValue:(int)value checksumPortion:(int)checksumPortion finderPattern:(ZXRSSFinderPattern *)finderPattern;
- (void)incrementCount;

@end

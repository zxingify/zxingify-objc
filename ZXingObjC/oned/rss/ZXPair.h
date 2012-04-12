#import "ZXDataCharacter.h"

@class ZXRSSFinderPattern;

@interface ZXPair : ZXDataCharacter {
  ZXRSSFinderPattern * finderPattern;
  int count;
}

@property (nonatomic, readonly) int count;
@property (nonatomic, readonly) ZXRSSFinderPattern * finderPattern;

- (id) initWithValue:(int)value checksumPortion:(int)checksumPortion finderPattern:(ZXRSSFinderPattern *)finderPattern;
- (void) incrementCount;

@end

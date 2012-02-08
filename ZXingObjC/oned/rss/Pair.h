#import "DataCharacter.h"

@class RSSFinderPattern;

@interface Pair : DataCharacter {
  RSSFinderPattern * finderPattern;
  int count;
}

@property (nonatomic, readonly) int count;
@property (nonatomic, readonly) RSSFinderPattern * finderPattern;

- (id) initWithValue:(int)value checksumPortion:(int)checksumPortion finderPattern:(RSSFinderPattern *)finderPattern;
- (void) incrementCount;

@end

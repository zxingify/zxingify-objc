#import "ZXAbstractRSSReader.h"

@class ZXDataCharacter, ZXExpandedPair, ZXResult, ZXRSSFinderPattern;

@interface ZXRSSExpandedReader : ZXAbstractRSSReader

- (NSMutableArray *)decodeRow2pairs:(int)rowNumber row:(ZXBitArray *)row;
- (ZXExpandedPair *)retrieveNextPair:(ZXBitArray *)row previousPairs:(NSMutableArray *)previousPairs rowNumber:(int)rowNumber;
- (ZXDataCharacter *)decodeDataCharacter:(ZXBitArray *)row pattern:(ZXRSSFinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar;

@end

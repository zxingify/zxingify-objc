#import "ZXAbstractRSSReader.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@class ZXDataCharacter, ZXExpandedPair, ZXResult, ZXRSSFinderPattern;

@interface ZXRSSExpandedReader : ZXAbstractRSSReader

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(NSMutableDictionary *)hints;
- (void) reset;
- (NSMutableArray *) decodeRow2pairs:(int)rowNumber row:(ZXBitArray *)row;
- (ZXExpandedPair *) retrieveNextPair:(ZXBitArray *)row previousPairs:(NSMutableArray *)previousPairs rowNumber:(int)rowNumber;
- (ZXDataCharacter *) decodeDataCharacter:(ZXBitArray *)row pattern:(ZXRSSFinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar;

@end

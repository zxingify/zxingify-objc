#import "AbstractRSSReader.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@class DataCharacter, ExpandedPair, Result, RSSFinderPattern;

@interface RSSExpandedReader : AbstractRSSReader

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
- (void) reset;
- (NSMutableArray *) decodeRow2pairs:(int)rowNumber row:(BitArray *)row;
- (ExpandedPair *) retrieveNextPair:(BitArray *)row previousPairs:(NSMutableArray *)previousPairs rowNumber:(int)rowNumber;
- (DataCharacter *) decodeDataCharacter:(BitArray *)row pattern:(RSSFinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar;

@end

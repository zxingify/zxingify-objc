#import "NSMutableDictionary.h"
#import "NSMutableArray.h"
#import "BarcodeFormat.h"
#import "NotFoundException.h"
#import "Result.h"
#import "ResultPoint.h"
#import "BitArray.h"
#import "AbstractRSSReader.h"
#import "DataCharacter.h"
#import "FinderPattern.h"
#import "RSSUtils.h"
#import "AbstractExpandedDecoder.h"

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */

@interface RSSExpandedReader : AbstractRSSReader {
  NSMutableArray * pairs;
  NSArray * startEnd;
  NSArray * currentSequence;
}

- (void) init;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
- (void) reset;
- (NSMutableArray *) decodeRow2pairs:(int)rowNumber row:(BitArray *)row;
- (ExpandedPair *) retrieveNextPair:(BitArray *)row previousPairs:(NSMutableArray *)previousPairs rowNumber:(int)rowNumber;
- (DataCharacter *) decodeDataCharacter:(BitArray *)row pattern:(FinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar;
@end

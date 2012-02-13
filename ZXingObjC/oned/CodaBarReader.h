#import "OneDReader.h"

/**
 * <p>Decodes Codabar barcodes.</p>
 * 
 * @author Bas Vijfwinkel
 */

@class BitArray, Result;

@interface CodaBarReader : OneDReader

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;

@end

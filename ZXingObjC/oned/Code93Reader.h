#import "OneDReader.h"

/**
 * <p>Decodes Code 93 barcodes.</p>
 * 
 * @author Sean Owen
 * @see Code39Reader
 */

@class BitArray, Result;

@interface Code93Reader : OneDReader

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;

@end

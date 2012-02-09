#import "OneDReader.h"

/**
 * <p>Decodes Code 128 barcodes.</p>
 * 
 * @author Sean Owen
 */

@class BitArray, Result;

@interface Code128Reader : OneDReader

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;

@end

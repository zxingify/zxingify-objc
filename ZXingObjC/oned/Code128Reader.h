#import "OneDReader.h"

/**
 * <p>Decodes Code 128 barcodes.</p>
 * 
 * @author Sean Owen
 */

extern const int CODE_PATTERNS[][7];

@class BitArray, Result;

@interface Code128Reader : OneDReader

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;

@end

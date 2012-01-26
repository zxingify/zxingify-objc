#import "NSMutableDictionary.h"
#import "BarcodeFormat.h"
#import "NotFoundException.h"
#import "Result.h"
#import "ResultPoint.h"
#import "BitArray.h"

/**
 * <p>Decodes Codabar barcodes.</p>
 * 
 * @author Bas Vijfwinkel
 */

@interface CodaBarReader : OneDReader {
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
@end

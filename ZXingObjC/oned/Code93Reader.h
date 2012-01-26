#import "NSMutableDictionary.h"
#import "BarcodeFormat.h"
#import "ChecksumException.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "Result.h"
#import "ResultPoint.h"
#import "BitArray.h"

/**
 * <p>Decodes Code 93 barcodes.</p>
 * 
 * @author Sean Owen
 * @see Code39Reader
 */

@interface Code93Reader : OneDReader {
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
@end

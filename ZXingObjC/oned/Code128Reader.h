#import "BarcodeFormat.h"
#import "ChecksumException.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "Result.h"
#import "ResultPoint.h"
#import "BitArray.h"

/**
 * <p>Decodes Code 128 barcodes.</p>
 * 
 * @author Sean Owen
 */

@interface Code128Reader : OneDReader {
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
@end

#import "BarcodeFormat.h"
#import "ChecksumException.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "Result.h"
#import "ResultPoint.h"
#import "BitArray.h"

/**
 * <p>Decodes Code 39 barcodes. This does not support "Full ASCII Code 39" yet.</p>
 * 
 * @author Sean Owen
 * @see Code93Reader
 */

@interface Code39Reader : OneDReader {
  BOOL usingCheckDigit;
  BOOL extendedMode;
}

- (id) init;
- (id) initWithUsingCheckDigit:(BOOL)usingCheckDigit;
- (id) init:(BOOL)usingCheckDigit extendedMode:(BOOL)extendedMode;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
@end

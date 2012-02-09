#import "OneDReader.h"

/**
 * <p>Decodes Code 39 barcodes. This does not support "Full ASCII Code 39" yet.</p>
 * 
 * @author Sean Owen
 * @see Code93Reader
 */

@class BitArray, Result;

@interface Code39Reader : OneDReader {
  BOOL usingCheckDigit;
  BOOL extendedMode;
}

- (id) initUsingCheckDigit:(BOOL)usingCheckDigit;
- (id) initUsingCheckDigit:(BOOL)usingCheckDigit extendedMode:(BOOL)extendedMode;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;

@end

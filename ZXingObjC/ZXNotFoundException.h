#import "ZXReaderException.h"

/**
 * Thrown when a barcode was not found in the image. It might have been
 * partially detected but could not be confirmed.
 * 
 * @author Sean Owen
 */

@interface ZXNotFoundException : ZXReaderException

+ (ZXNotFoundException *)notFoundInstance;

@end

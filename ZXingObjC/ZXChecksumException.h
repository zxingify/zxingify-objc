#import "ZXReaderException.h"

/**
 * Thrown when a barcode was successfully detected and decoded, but
 * was not returned because its checksum feature failed.
 * 
 * @author Sean Owen
 */

@interface ZXChecksumException : ZXReaderException

+ (ZXChecksumException *)checksumInstance;

@end

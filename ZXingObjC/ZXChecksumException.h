#import "ZXReaderException.h"

/**
 * Thrown when a barcode was successfully detected and decoded, but
 * was not returned because its checksum feature failed.
 */

@interface ZXChecksumException : ZXReaderException

+ (ZXChecksumException *)checksumInstance;

@end

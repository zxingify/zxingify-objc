#import "ReaderException.h"

/**
 * Thrown when a barcode was successfully detected and decoded, but
 * was not returned because its checksum feature failed.
 * 
 * @author Sean Owen
 */

@interface ChecksumException : ReaderException

+ (ChecksumException *)checksumInstance;

@end

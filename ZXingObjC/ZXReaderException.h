
/**
 * The general exception class throw when something goes wrong during decoding of a barcode.
 * This includes, but is not limited to, failing checksums / error correction algorithms, being
 * unable to locate finder timing patterns, and so on.
 * 
 * @author Sean Owen
 */

@interface ZXReaderException : NSException
@end

#import "ZXErrorCorrectionLevel.h"

/**
 * These are a set of hints that you may pass to Writers to specify their behavior.
 */

@interface ZXEncodeHints : NSObject

/**
 * Specifies what character encoding to use where applicable (type String)
 */
@property (nonatomic, assign) NSStringEncoding encoding;

/**
 * Specifies what degree of error correction to use, for example in QR Codes (type Integer).
 */
@property (nonatomic, retain) ZXErrorCorrectionLevel *errorCorrectionLevel;

@end

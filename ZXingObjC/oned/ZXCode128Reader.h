#import "ZXOneDReader.h"

/**
 * Decodes Code 128 barcodes.
 */

extern const int CODE_PATTERNS[][7];

@class ZXDecodeHints, ZXResult;

@interface ZXCode128Reader : ZXOneDReader

@end

#import "ZXOneDReader.h"

/**
 * Decodes Code 39 barcodes. This does not support "Full ASCII Code 39" yet.
 */

extern char CODE39_ALPHABET[];
extern NSString *CODE39_ALPHABET_STRING;
extern int CODE39_CHARACTER_ENCODINGS[];

@class ZXDecodeHints, ZXResult;

@interface ZXCode39Reader : ZXOneDReader

- (id)initUsingCheckDigit:(BOOL)usingCheckDigit;
- (id)initUsingCheckDigit:(BOOL)usingCheckDigit extendedMode:(BOOL)extendedMode;

@end

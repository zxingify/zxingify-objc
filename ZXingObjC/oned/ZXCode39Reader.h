#import "ZXOneDReader.h"

/**
 * <p>Decodes Code 39 barcodes. This does not support "Full ASCII Code 39" yet.</p>
 * 
 * @author Sean Owen
 * @see ZXCode93Reader
 */

extern char CODE39_ALPHABET[];
extern NSString *CODE39_ALPHABET_STRING;
extern int CODE39_CHARACTER_ENCODINGS[];

@class ZXDecodeHints, ZXResult;

@interface ZXCode39Reader : ZXOneDReader {
  BOOL usingCheckDigit;
  BOOL extendedMode;
}

- (id) initUsingCheckDigit:(BOOL)usingCheckDigit;
- (id) initUsingCheckDigit:(BOOL)usingCheckDigit extendedMode:(BOOL)extendedMode;
- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints;

@end

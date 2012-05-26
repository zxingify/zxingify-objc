#import "ZXOneDReader.h"

/**
 * Decodes Code 128 barcodes.
 */

extern const int CODE_PATTERNS[][7];

extern const int CODE_START_B;
extern const int CODE_START_C;
extern const int CODE_CODE_B;
extern const int CODE_CODE_C;
extern const int CODE_STOP;

extern int const CODE_FNC_1;
extern int const CODE_FNC_2;
extern int const CODE_FNC_3;
extern int const CODE_FNC_4_A;
extern int const CODE_FNC_4_B;

@class ZXDecodeHints, ZXResult;

@interface ZXCode128Reader : ZXOneDReader

@end

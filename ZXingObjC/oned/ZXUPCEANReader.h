#import "ZXBarcodeFormat.h"
#import "ZXOneDReader.h"

/**
 * Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.
 */

typedef enum {
	UPC_EAN_PATTERNS_L_PATTERNS = 0,
	UPC_EAN_PATTERNS_L_AND_G_PATTERNS
} UPC_EAN_PATTERNS;

extern const int START_END_PATTERN_LEN;
extern const int START_END_PATTERN[];
extern const int MIDDLE_PATTERN_LEN;
extern const int MIDDLE_PATTERN[];
extern const int L_PATTERNS_SUB_LEN;
extern const int L_PATTERNS[][4];
extern const int L_AND_G_PATTERNS[][4];

@class ZXDecodeHints, ZXEANManufacturerOrgSupport, ZXResult, ZXUPCEANExtensionSupport;

@interface ZXUPCEANReader : ZXOneDReader

- (ZXBarcodeFormat)barcodeFormat;
- (BOOL)checkChecksum:(NSString *)s error:(NSError**)error;
+ (int)decodeDigit:(ZXBitArray *)row counters:(int[])counters countersLen:(int)countersLen rowOffset:(int)rowOffset patternType:(UPC_EAN_PATTERNS)patternType error:(NSError**)error;
- (NSArray *)decodeEnd:(ZXBitArray *)row endStart:(int)endStart error:(NSError**)error;
- (int)decodeMiddle:(ZXBitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result error:(NSError**)error;
- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(ZXDecodeHints *)hints error:(NSError**)error;
+ (NSArray *)findStartGuardPattern:(ZXBitArray *)row error:(NSError**)error;
+ (NSArray *)findGuardPattern:(ZXBitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(int*)pattern patternLen:(int)patternLen error:(NSError**)error;

@end

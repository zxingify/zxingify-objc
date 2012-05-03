#import "ZXBarcodeFormat.h"
#import "ZXOneDReader.h"

/**
 * <p>Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.</p>
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 * @author alasdair@google.com (Alasdair Mackintosh)
 */

typedef enum {
	UPC_EAN_PATTERNS_L_PATTERNS = 0,
	UPC_EAN_PATTERNS_L_AND_G_PATTERNS
} UPC_EAN_PATTERNS;

extern const int START_END_PATTERN[];
extern const int MIDDLE_PATTERN_LEN;
extern const int MIDDLE_PATTERN[];
extern const int L_PATTERNS[][4];
extern const int L_AND_G_PATTERNS[][4];

@class ZXDecodeHints, ZXEANManufacturerOrgSupport, ZXResult, ZXUPCEANExtensionSupport;

@interface ZXUPCEANReader : ZXOneDReader {
  NSMutableString * decodeRowNSMutableString;
  ZXUPCEANExtensionSupport * extensionReader;
  ZXEANManufacturerOrgSupport * eanManSupport;
}

- (ZXBarcodeFormat) barcodeFormat;
- (BOOL) checkChecksum:(NSString *)s;
+ (int) decodeDigit:(ZXBitArray *)row counters:(int[])counters countersLen:(int)countersLen rowOffset:(int)rowOffset patternType:(UPC_EAN_PATTERNS)patternType;
- (NSArray *) decodeEnd:(ZXBitArray *)row endStart:(int)endStart;
- (int) decodeMiddle:(ZXBitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result;
- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(ZXDecodeHints *)hints;
+ (NSArray *) findStartGuardPattern:(ZXBitArray *)row;
+ (NSArray *) findGuardPattern:(ZXBitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(int[])pattern patternLen:(int)patternLen;

@end

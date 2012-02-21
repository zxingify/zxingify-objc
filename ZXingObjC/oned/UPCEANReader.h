#import "BarcodeFormat.h"
#import "OneDReader.h"

/**
 * <p>Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.</p>
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 * @author alasdair@google.com (Alasdair Mackintosh)
 */

extern const int START_END_PATTERN[];
extern const int MIDDLE_PATTERN[];
extern const int L_PATTERNS[][4];
extern int L_AND_G_PATTERNS[][4];

@class BitArray, EANManufacturerOrgSupport, Result, UPCEANExtensionSupport;

@interface UPCEANReader : OneDReader {
  NSMutableString * decodeRowNSMutableString;
  UPCEANExtensionSupport * extensionReader;
  EANManufacturerOrgSupport * eanManSupport;
}

- (BarcodeFormat) barcodeFormat;
- (BOOL) checkChecksum:(NSString *)s;
+ (int) decodeDigit:(BitArray *)row counters:(int[])counters rowOffset:(int)rowOffset patterns:(int*[])patterns;
- (NSArray *) decodeEnd:(BitArray *)row endStart:(int)endStart;
- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(NSMutableDictionary *)hints;
+ (NSArray *) findStartGuardPattern:(BitArray *)row;
+ (NSArray *) findGuardPattern:(BitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(int[])pattern;

@end

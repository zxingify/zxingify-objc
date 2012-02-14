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

extern int L_AND_G_PATTERNS[20][4];

@class BitArray, EANManufacturerOrgSupport, Result, UPCEANExtensionSupport;

@interface UPCEANReader : OneDReader {
  NSMutableString * decodeRowNSMutableString;
  UPCEANExtensionSupport * extensionReader;
  EANManufacturerOrgSupport * eanManSupport;
}

+ (NSArray *) findStartGuardPattern:(BitArray *)row;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(NSMutableDictionary *)hints;
- (BOOL) checkChecksum:(NSString *)s;
- (NSArray *) decodeEnd:(BitArray *)row endStart:(int)endStart;
+ (NSArray *) findGuardPattern:(BitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(int[])pattern;
+ (int) decodeDigit:(BitArray *)row counters:(int[])counters rowOffset:(int)rowOffset patterns:(int*[])patterns;
- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange resultString:(NSMutableString *)resultString;
- (BarcodeFormat) barcodeFormat;

@end

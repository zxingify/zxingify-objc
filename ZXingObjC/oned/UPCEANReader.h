#import "BarcodeFormat.h"
#import "ChecksumException.h"
#import "DecodeHintType.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "ReaderException.h"
#import "Result.h"
#import "ResultMetadataType.h"
#import "ResultPoint.h"
#import "ResultPointCallback.h"
#import "BitArray.h"

/**
 * <p>Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.</p>
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 * @author alasdair@google.com (Alasdair Mackintosh)
 */

@interface UPCEANReader : OneDReader {
  StringBuffer * decodeRowStringBuffer;
  UPCEANExtensionSupport * extensionReader;
  EANManufacturerOrgSupport * eanManSupport;
}

+ (void) initialize;
- (id) init;
+ (NSArray *) findStartGuardPattern:(BitArray *)row;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(NSMutableDictionary *)hints;
- (BOOL) checkChecksum:(NSString *)s;
- (NSArray *) decodeEnd:(BitArray *)row endStart:(int)endStart;
+ (NSArray *) findGuardPattern:(BitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(NSArray *)pattern;
+ (int) decodeDigit:(BitArray *)row counters:(NSArray *)counters rowOffset:(int)rowOffset patterns:(NSArray *)patterns;
- (BarcodeFormat *) getBarcodeFormat;
- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange resultString:(StringBuffer *)resultString;
@end

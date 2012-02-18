#import "BarcodeFormat.h"
#import "BinaryBitmap.h"
#import "ChecksumException.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "Result.h"
#import "BitArray.h"

/**
 * <p>Implements decoding of the UPC-A format.</p>
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

@interface UPCAReader : UPCEANReader {
  UPCEANReader * ean13Reader;
}

- (void) init;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(NSMutableDictionary *)hints;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
- (Result *) decode:(BinaryBitmap *)image;
- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (BarcodeFormat) getBarcodeFormat;
- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange resultString:(NSMutableString *)resultString;
@end

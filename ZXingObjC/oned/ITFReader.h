#import "BarcodeFormat.h"
#import "DecodeHintType.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "Result.h"
#import "ResultPoint.h"
#import "BitArray.h"
#import "NSMutableDictionary.h"

/**
 * <p>Implements decoding of the ITF format, or Interleaved Two of Five.</p>
 * 
 * <p>This Reader will scan ITF barcodes of certain lengths only.
 * At the moment it reads length 6, 10, 12, 14, 16, 24, and 44 as these have appeared "in the wild". Not all
 * lengths are scanned, especially shorter ones, to avoid false positives. This in turn is due to a lack of
 * required checksum function.</p>
 * 
 * <p>The checksum is optional and is not applied by this Reader. The consumer of the decoded
 * value will have to apply a checksum if required.</p>
 * 
 * <p><a href="http://en.wikipedia.org/wiki/Interleaved_2_of_5">http://en.wikipedia.org/wiki/Interleaved_2_of_5</a>
 * is a great reference for Interleaved 2 of 5 information.</p>
 * 
 * @author kevin.osullivan@sita.aero, SITA Lab.
 */

@interface ITFReader : OneDReader {
  int narrowLineWidth;
}

- (void) init;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
- (NSArray *) decodeStart:(BitArray *)row;
- (NSArray *) decodeEnd:(BitArray *)row;
@end

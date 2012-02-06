#import "BarcodeFormat.h"
#import "DecodeHintType.h"
#import "NotFoundException.h"
#import "Reader.h"
#import "ReaderException.h"
#import "Result.h"
#import "BitArray.h"

/**
 * <p>A reader that can read all available UPC/EAN formats. If a caller wants to try to
 * read all such formats, it is most efficient to use this implementation rather than invoke
 * individual readers.</p>
 * 
 * @author Sean Owen
 */

@interface MultiFormatUPCEANReader : OneDReader {
  NSMutableArray * readers;
}

- (id) initWithHints:(NSMutableDictionary *)hints;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
- (void) reset;
@end

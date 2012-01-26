#import "BarcodeFormat.h"
#import "DecodeHintType.h"
#import "NotFoundException.h"
#import "Reader.h"
#import "ReaderException.h"
#import "Result.h"
#import "BitArray.h"
#import "RSS14Reader.h"
#import "RSSExpandedReader.h"
#import "NSMutableDictionary.h"
#import "NSMutableArray.h"

/**
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

@interface MultiFormatOneDReader : OneDReader {
  NSMutableArray * readers;
}

- (id) initWithHints:(NSMutableDictionary *)hints;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
- (void) reset;
@end

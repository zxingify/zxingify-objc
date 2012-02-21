#import "OneDReader.h"

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

@end

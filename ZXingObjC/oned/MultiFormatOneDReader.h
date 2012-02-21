#import "OneDReader.h"

/**
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

@interface MultiFormatOneDReader : OneDReader {
  NSMutableArray * readers;
}

- (id) initWithHints:(NSMutableDictionary *)hints;

@end

#import "ZXOneDReader.h"

/**
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

@interface ZXMultiFormatOneDReader : ZXOneDReader {
  NSMutableArray * readers;
}

- (id) initWithHints:(NSMutableDictionary *)hints;

@end

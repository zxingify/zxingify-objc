#import "ZXOneDReader.h"

/**
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

@class ZXDecodeHints;

@interface ZXMultiFormatOneDReader : ZXOneDReader {
  NSMutableArray * readers;
}

- (id) initWithHints:(ZXDecodeHints *)hints;

@end

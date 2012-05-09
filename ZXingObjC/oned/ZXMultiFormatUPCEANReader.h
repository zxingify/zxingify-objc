#import "ZXOneDReader.h"

/**
 * A reader that can read all available UPC/EAN formats. If a caller wants to try to
 * read all such formats, it is most efficient to use this implementation rather than invoke
 * individual readers.
 */

@class ZXDecodeHints;

@interface ZXMultiFormatUPCEANReader : ZXOneDReader

- (id)initWithHints:(ZXDecodeHints *)hints;

@end

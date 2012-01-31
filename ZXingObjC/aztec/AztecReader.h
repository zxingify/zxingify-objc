#import "Reader.h"

/**
 * This implementation can detect and decode Aztec codes in an image.
 * 
 * @author David Olivier
 */

@class BinaryBitmap, Result;

@interface AztecReader : NSObject <Reader>

- (Result *)decode:(BinaryBitmap *)image;
- (Result *)decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (void)reset;

@end

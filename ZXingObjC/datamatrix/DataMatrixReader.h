#import "Reader.h"

/**
 * This implementation can detect and decode Data Matrix codes in an image.
 * 
 * @author bbrown@google.com (Brian Brown)
 */

@class BinaryBitmap, DataMatrixDecoder, Result;

@interface DataMatrixReader : NSObject <Reader> {
  DataMatrixDecoder * decoder;
}

- (Result *) decode:(BinaryBitmap *)image;
- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (void) reset;

@end

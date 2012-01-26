#import "BinaryBitmap.h"
#import "NotFoundException.h"
#import "Result.h"
#import "NSMutableDictionary.h"

/**
 * Implementation of this interface attempt to read several barcodes from one image.
 * 
 * @see com.google.zxing.Reader
 * @author Sean Owen
 */

@protocol MultipleBarcodeReader <NSObject>
- (NSArray *) decodeMultiple:(BinaryBitmap *)image;
- (NSArray *) decodeMultiple:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
@end

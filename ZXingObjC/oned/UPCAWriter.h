#import "BarcodeFormat.h"
#import "Writer.h"
#import "BitMatrix.h"

/**
 * This object renders a UPC-A code as a {@link BitMatrix}.
 * 
 * @author qwandor@google.com (Andrew Walbran)
 */

@interface UPCAWriter : NSObject <Writer>

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat)format width:(int)width height:(int)height;
- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints;

@end

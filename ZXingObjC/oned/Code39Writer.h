#import "BarcodeFormat.h"
#import "WriterException.h"
#import "BitMatrix.h"

/**
 * This object renders a CODE39 code as a {@link BitMatrix}.
 * 
 * @author erik.barbara@gmail.com (Erik Barbara)
 */

@interface Code39Writer : UPCEANWriter {
}

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints;
- (NSArray *) encode:(NSString *)contents;
@end

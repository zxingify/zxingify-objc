#import "BarcodeFormat.h"
#import "WriterException.h"
#import "BitMatrix.h"

/**
 * This object renders a ITF code as a {@link BitMatrix}.
 * 
 * @author erik.barbara@gmail.com (Erik Barbara)
 */

@interface ITFWriter : UPCEANWriter

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints;
- (NSArray *) encode:(NSString *)contents;

@end

#import "BarcodeFormat.h"
#import "WriterException.h"
#import "BitMatrix.h"

/**
 * This object renders an EAN13 code as a {@link BitMatrix}.
 * 
 * @author aripollak@gmail.com (Ari Pollak)
 */

@interface EAN13Writer : UPCEANWriter {
}

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints;
- (NSArray *) encode:(NSString *)contents;
@end

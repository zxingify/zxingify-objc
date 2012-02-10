#import "BarcodeFormat.h"
#import "UPCEANWriter.h"

/**
 * This object renders an EAN8 code as a {@link BitMatrix}.
 * 
 * @author aripollak@gmail.com (Ari Pollak)
 */

@class BitArray;

@interface EAN8Writer : UPCEANWriter

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints;
- (NSArray *) encode:(NSString *)contents;

@end

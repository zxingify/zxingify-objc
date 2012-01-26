#import "BarcodeFormat.h"
#import "Writer.h"
#import "WriterException.h"
#import "BitMatrix.h"

/**
 * <p>Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.</p>
 * 
 * @author aripollak@gmail.com (Ari Pollak)
 */

@interface UPCEANWriter : NSObject <Writer> {
}

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height;
- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints;
+ (int) appendPattern:(NSArray *)target pos:(int)pos pattern:(NSArray *)pattern startColor:(int)startColor;
- (NSArray *) encode:(NSString *)contents;
@end

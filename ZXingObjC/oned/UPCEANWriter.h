#import "Writer.h"

/**
 * <p>Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.</p>
 * 
 * @author aripollak@gmail.com (Ari Pollak)
 */

@interface UPCEANWriter : NSObject <Writer>

+ (int) appendPattern:(NSMutableArray *)target pos:(int)pos pattern:(int[])pattern startColor:(int)startColor;
- (NSArray *) encode:(NSString *)contents;

@end

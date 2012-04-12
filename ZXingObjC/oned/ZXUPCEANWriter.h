#import "ZXWriter.h"

/**
 * <p>Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.</p>
 * 
 * @author aripollak@gmail.com (Ari Pollak)
 */

@interface ZXUPCEANWriter : NSObject <ZXWriter>

+ (int) appendPattern:(NSMutableArray *)target pos:(int)pos pattern:(int[])pattern startColor:(int)startColor;
- (NSArray *) encode:(NSString *)contents;

@end

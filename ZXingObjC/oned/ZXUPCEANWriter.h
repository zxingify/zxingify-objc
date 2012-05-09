#import "ZXWriter.h"

/**
 * Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.
 */

@interface ZXUPCEANWriter : NSObject <ZXWriter>

+ (int)appendPattern:(NSMutableArray *)target pos:(int)pos pattern:(int*)pattern patternLen:(unsigned int)patternLen startColor:(int)startColor;
- (NSArray *)encode:(NSString *)contents;

@end

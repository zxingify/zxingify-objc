#import "ZXFinderPatternFinder.h"

/**
 * This class attempts to find finder patterns in a QR Code. Finder patterns are the square
 * markers at three corners of a QR Code.
 * 
 * This class is thread-safe but not reentrant. Each thread must allocate its own object.
 * 
 * In contrast to ZXFinderPatternFinder, this class will return an array of all possible
 * QR code locations in the image.
 * 
 * Use the tryHarder hint to ask for a more thorough detection.
 */

@class ZXDecodeHints;

@interface ZXMultiFinderPatternFinder : ZXFinderPatternFinder

- (NSArray *)findMulti:(ZXDecodeHints *)hints error:(NSError**)error;

@end

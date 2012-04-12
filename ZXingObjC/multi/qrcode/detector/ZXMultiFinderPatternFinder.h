#import "ZXFinderPatternFinder.h"

/**
 * <p>This class attempts to find finder patterns in a QR Code. Finder patterns are the square
 * markers at three corners of a QR Code.</p>
 * 
 * <p>This class is thread-safe but not reentrant. Each thread must allocate its own object.
 * 
 * <p>In contrast to {@link FinderPatternFinder}, this class will return an array of all possible
 * QR code locations in the image.</p>
 * 
 * <p>Use the TRY_HARDER hint to ask for a more thorough detection.</p>
 * 
 * @author Sean Owen
 * @author Hannes Erven
 */

@interface ZXMultiFinderPatternFinder : ZXFinderPatternFinder

- (NSArray *) findMulti:(NSMutableDictionary *)hints;

@end

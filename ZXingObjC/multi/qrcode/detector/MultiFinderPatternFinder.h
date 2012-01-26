#import "DecodeHintType.h"
#import "NotFoundException.h"
#import "ResultPoint.h"
#import "ResultPointCallback.h"
#import "BitMatrix.h"
#import "Collections.h"
#import "Comparator.h"
#import "FinderPattern.h"
#import "FinderPatternFinder.h"
#import "FinderPatternInfo.h"
#import "NSMutableDictionary.h"
#import "NSMutableArray.h"

/**
 * A comparator that orders FinderPatterns by their estimated module size.
 */

@interface ModuleSizeComparator : NSObject <Comparator> {
}

- (int) compare:(NSObject *)center1 center2:(NSObject *)center2;
@end

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

@interface MultiFinderPatternFinder : FinderPatternFinder {
}

- (id) initWithImage:(BitMatrix *)image;
- (id) init:(BitMatrix *)image resultPointCallback:(ResultPointCallback *)resultPointCallback;
- (NSArray *) findMulti:(NSMutableDictionary *)hints;
@end

#import "NSMutableArray.h"

/**
 * <p>This is basically a substitute for <code>java.util.Collections</code>, which is not
 * present in MIDP 2.0 / CLDC 1.1.</p>
 * 
 * @author Sean Owen
 */

@interface Collections : NSObject {
}

+ (void) insertionSort:(NSMutableArray *)vector comparator:(Comparator *)comparator;
@end

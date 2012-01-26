
/**
 * This is merely a clone of <code>Comparator</code> since it is not available in
 * CLDC 1.1 / MIDP 2.0.
 */

@protocol Comparator <NSObject>
- (int) compare:(NSObject *)o1 o2:(NSObject *)o2;
@end

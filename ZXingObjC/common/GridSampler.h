/**
 * Implementations of this class can, given locations of finder patterns for a QR code in an
 * image, sample the right points in the image to reconstruct the QR code, accounting for
 * perspective distortion. It is abstracted since it is relatively expensive and should be allowed
 * to take advantage of platform-specific optimized implementations, like Sun's Java Advanced
 * Imaging library, but which may not be available in other environments such as J2ME, and vice
 * versa.
 * 
 * The implementation used can be controlled by calling {@link #setGridSampler(GridSampler)}
 * with an instance of a class which implements this interface.
 * 
 * @author Sean Owen
 */

@class BitMatrix, PerspectiveTransform;

@interface GridSampler : NSObject

+ (GridSampler *)instance;
+ (void) setGridSampler:(GridSampler *)newGridSampler;
- (BitMatrix *) sampleGrid:(BitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY p1ToX:(float)p1ToX p1ToY:(float)p1ToY p2ToX:(float)p2ToX p2ToY:(float)p2ToY p3ToX:(float)p3ToX p3ToY:(float)p3ToY p4ToX:(float)p4ToX p4ToY:(float)p4ToY p1FromX:(float)p1FromX p1FromY:(float)p1FromY p2FromX:(float)p2FromX p2FromY:(float)p2FromY p3FromX:(float)p3FromX p3FromY:(float)p3FromY p4FromX:(float)p4FromX p4FromY:(float)p4FromY;
- (BitMatrix *) sampleGrid:(BitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY transform:(PerspectiveTransform *)transform;
+ (void) checkAndNudgePoints:(BitMatrix *)image points:(NSMutableArray *)points;

@end

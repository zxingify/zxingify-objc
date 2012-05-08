/**
 * Encapsulates a point of interest in an image containing a barcode. Typically, this
 * would be the location of a finder pattern or the corner of the barcode, for example.
 */

@interface ZXResultPoint : NSObject<NSCopying>

@property (nonatomic, assign, readonly) float x;
@property (nonatomic, assign, readonly) float y;

- (id)initWithX:(float)x y:(float)y;
+ (void)orderBestPatterns:(NSMutableArray *)patterns;
+ (float)distance:(ZXResultPoint *)pattern1 pattern2:(ZXResultPoint *)pattern2;

@end

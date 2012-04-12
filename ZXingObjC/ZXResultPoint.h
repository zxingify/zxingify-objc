
/**
 * <p>Encapsulates a point of interest in an image containing a barcode. Typically, this
 * would be the location of a finder pattern or the corner of the barcode, for example.</p>
 * 
 * @author Sean Owen
 */

@interface ZXResultPoint : NSObject {
  float x;
  float y;
}

@property(nonatomic, readonly) float x;
@property(nonatomic, readonly) float y;

- (id) initWithX:(float)x y:(float)y;
+ (void) orderBestPatterns:(NSMutableArray *)patterns;
+ (float) distance:(ZXResultPoint *)pattern1 pattern2:(ZXResultPoint *)pattern2;

@end

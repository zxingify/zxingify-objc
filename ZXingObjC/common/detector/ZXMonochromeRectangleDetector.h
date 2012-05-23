/**
 * A somewhat generic detector that looks for a barcode-like rectangular region within an image.
 * It looks within a mostly white region of an image for a region of black and white, but mostly
 * black. It returns the four corners of the region, as best it can determine.
 */

@class ZXBitMatrix;

@interface ZXMonochromeRectangleDetector : NSObject

- (id)initWithImage:(ZXBitMatrix *)image;
- (NSArray *)detectWithError:(NSError**)error;

@end

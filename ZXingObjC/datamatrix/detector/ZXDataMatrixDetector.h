/**
 * Encapsulates logic that can detect a Data Matrix Code in an image, even if the Data Matrix Code
 * is rotated or skewed, or partially obscured.
 */

@class ZXBitMatrix, ZXDetectorResult, ZXWhiteRectangleDetector;

@interface ZXDataMatrixDetector : NSObject

- (id)initWithImage:(ZXBitMatrix *)image;
- (ZXDetectorResult *)detect;

@end

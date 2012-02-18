/**
 * <p>Encapsulates logic that can detect a Data Matrix Code in an image, even if the Data Matrix Code
 * is rotated or skewed, or partially obscured.</p>
 * 
 * @author Sean Owen
 */

@class BitMatrix, DetectorResult, WhiteRectangleDetector;

@interface DataMatrixDetector : NSObject {
  BitMatrix * image;
  WhiteRectangleDetector * rectangleDetector;
}

- (id) initWithImage:(BitMatrix *)image;
- (DetectorResult *) detect;

@end

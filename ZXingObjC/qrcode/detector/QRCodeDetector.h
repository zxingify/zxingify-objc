/**
 * <p>Encapsulates logic that can detect a QR Code in an image, even if the QR Code
 * is rotated or skewed, or partially obscured.</p>
 * 
 * @author Sean Owen
 */

@class AlignmentPattern, BitMatrix, DetectorResult, FinderPatternInfo, PerspectiveTransform, ResultPoint;
@protocol ResultPointCallback;

@interface QRCodeDetector : NSObject {
  BitMatrix * image;
  id <ResultPointCallback> resultPointCallback;
}

@property (nonatomic, readonly) BitMatrix * image;
@property (nonatomic, readonly) id <ResultPointCallback> resultPointCallback;

- (id) initWithImage:(BitMatrix *)image;
- (DetectorResult *) detect;
- (DetectorResult *) detect:(NSMutableDictionary *)hints;
- (DetectorResult *) processFinderPatternInfo:(FinderPatternInfo *)info;
+ (PerspectiveTransform *) createTransform:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft alignmentPattern:(ResultPoint *)alignmentPattern dimension:(int)dimension;
+ (int) computeDimension:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft moduleSize:(float)moduleSize;
- (float) calculateModuleSize:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft;
- (AlignmentPattern *) findAlignmentInRegion:(float)overallEstModuleSize estAlignmentX:(int)estAlignmentX estAlignmentY:(int)estAlignmentY allowanceFactor:(float)allowanceFactor;

@end

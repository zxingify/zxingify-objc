#import "DecodeHintType.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "ResultPoint.h"
#import "ResultPointCallback.h"
#import "BitMatrix.h"
#import "DetectorResult.h"
#import "GridSampler.h"
#import "PerspectiveTransform.h"
#import "QRCodeVersion.h"

/**
 * <p>Encapsulates logic that can detect a QR Code in an image, even if the QR Code
 * is rotated or skewed, or partially obscured.</p>
 * 
 * @author Sean Owen
 */

@interface QRCodeDetector : NSObject {
  BitMatrix * image;
  id <ResultPointCallback> resultPointCallback;
}

- (id) initWithImage:(BitMatrix *)image;
- (BitMatrix *) getImage;
- (id <ResultPointCallback>) getResultPointCallback;
- (DetectorResult *) detect;
- (DetectorResult *) detect:(NSMutableDictionary *)hints;
- (DetectorResult *) processFinderPatternInfo:(FinderPatternInfo *)info;
+ (PerspectiveTransform *) createTransform:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft alignmentPattern:(ResultPoint *)alignmentPattern dimension:(int)dimension;
+ (int) computeDimension:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft moduleSize:(float)moduleSize;
- (float) calculateModuleSize:(ResultPoint *)topLeft topRight:(ResultPoint *)topRight bottomLeft:(ResultPoint *)bottomLeft;
- (AlignmentPattern *) findAlignmentInRegion:(float)overallEstModuleSize estAlignmentX:(int)estAlignmentX estAlignmentY:(int)estAlignmentY allowanceFactor:(float)allowanceFactor;
@end

/**
 * Encapsulates logic that can detect a QR Code in an image, even if the QR Code
 * is rotated or skewed, or partially obscured.
 */

@class ZXAlignmentPattern, ZXBitMatrix, ZXDecodeHints, ZXDetectorResult, ZXFinderPatternInfo, ZXPerspectiveTransform, ZXResultPoint;
@protocol ZXResultPointCallback;

@interface ZXQRCodeDetector : NSObject

@property (nonatomic, retain, readonly) ZXBitMatrix * image;
@property (nonatomic, assign, readonly) id <ZXResultPointCallback> resultPointCallback;

- (id)initWithImage:(ZXBitMatrix *)image;
- (ZXDetectorResult *)detect;
- (ZXDetectorResult *)detect:(ZXDecodeHints *)hints;
- (ZXDetectorResult *)processFinderPatternInfo:(ZXFinderPatternInfo *)info;
+ (ZXPerspectiveTransform *)createTransform:(ZXResultPoint *)topLeft topRight:(ZXResultPoint *)topRight bottomLeft:(ZXResultPoint *)bottomLeft alignmentPattern:(ZXResultPoint *)alignmentPattern dimension:(int)dimension;
+ (int)computeDimension:(ZXResultPoint *)topLeft topRight:(ZXResultPoint *)topRight bottomLeft:(ZXResultPoint *)bottomLeft moduleSize:(float)moduleSize;
- (float)calculateModuleSize:(ZXResultPoint *)topLeft topRight:(ZXResultPoint *)topRight bottomLeft:(ZXResultPoint *)bottomLeft;
- (ZXAlignmentPattern *)findAlignmentInRegion:(float)overallEstModuleSize estAlignmentX:(int)estAlignmentX estAlignmentY:(int)estAlignmentY allowanceFactor:(float)allowanceFactor;

@end

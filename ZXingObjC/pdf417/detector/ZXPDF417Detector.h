/**
 * Encapsulates logic that can detect a PDF417 Code in an image, even if the
 * PDF417 Code is rotated or skewed, or partially obscured.
 */

@class ZXBinaryBitmap, ZXDecodeHints, ZXDetectorResult;

@interface ZXPDF417Detector : NSObject

- (id)initWithImage:(ZXBinaryBitmap *)image;
- (ZXDetectorResult *)detectWithError:(NSError**)error;
- (ZXDetectorResult *)detect:(ZXDecodeHints *)hints error:(NSError**)error;

@end

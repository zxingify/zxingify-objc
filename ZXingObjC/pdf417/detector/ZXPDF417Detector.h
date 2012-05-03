/**
 * <p>Encapsulates logic that can detect a PDF417 Code in an image, even if the
 * PDF417 Code is rotated or skewed, or partially obscured.</p>
 * 
 * @author SITA Lab (kevin.osullivan@sita.aero)
 * @author dswitkin@google.com (Daniel Switkin)
 */

@class ZXBinaryBitmap, ZXDecodeHints, ZXDetectorResult;

@interface ZXPDF417Detector : NSObject {
  ZXBinaryBitmap * image;
}

- (id) initWithImage:(ZXBinaryBitmap *)image;
- (ZXDetectorResult *) detect;
- (ZXDetectorResult *) detect:(ZXDecodeHints *)hints;

@end

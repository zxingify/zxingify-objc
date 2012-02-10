/**
 * <p>Encapsulates logic that can detect a PDF417 Code in an image, even if the
 * PDF417 Code is rotated or skewed, or partially obscured.</p>
 * 
 * @author SITA Lab (kevin.osullivan@sita.aero)
 * @author dswitkin@google.com (Daniel Switkin)
 */

@class BinaryBitmap, DetectorResult;

@interface PDF417Detector : NSObject {
  BinaryBitmap * image;
}

- (id) initWithImage:(BinaryBitmap *)image;
- (DetectorResult *) detect;
- (DetectorResult *) detect:(NSMutableDictionary *)hints;

@end

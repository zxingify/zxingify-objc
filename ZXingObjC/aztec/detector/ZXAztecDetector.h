/**
 * Encapsulates logic that can detect an Aztec Code in an image, even if the Aztec Code
 * is rotated or skewed, or partially obscured.
 */

@class ZXAztecDetectorResult, ZXBitMatrix;

@interface ZXAztecDetector : NSObject

- (id)initWithImage:(ZXBitMatrix *)image;
- (ZXAztecDetectorResult *)detectWithError:(NSError**)error;

@end

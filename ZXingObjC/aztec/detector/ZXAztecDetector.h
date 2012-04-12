/**
 * <p>Encapsulates logic that can detect an Aztec Code in an image, even if the Aztec Code
 * is rotated or skewed, or partially obscured.</p>
 * 
 * @author David Olivier
 */

@class ZXAztecDetectorResult, ZXBitMatrix;

@interface ZXAztecDetector : NSObject {
  ZXBitMatrix * image;
  BOOL compact;
  int nbLayers;
  int nbDataBlocks;
  int nbCenterLayers;
  int shift;
}

- (id) initWithImage:(ZXBitMatrix *)image;
- (ZXAztecDetectorResult *) detect;

@end

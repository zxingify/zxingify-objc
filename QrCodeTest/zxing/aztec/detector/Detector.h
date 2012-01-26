#import "NotFoundException.h"
#import "ResultPoint.h"
#import "AztecDetectorResult.h"
#import "BitMatrix.h"
#import "GridSampler.h"
#import "WhiteRectangleDetector.h"
#import "GenericGF.h"
#import "ReedSolomonDecoder.h"
#import "ReedSolomonException.h"

@interface Point : NSObject {
  int x;
  int y;
}

- (ResultPoint *) toResultPoint;
@end

/**
 * <p>Encapsulates logic that can detect an Aztec Code in an image, even if the Aztec Code
 * is rotated or skewed, or partially obscured.</p>
 * 
 * @author David Olivier
 */

@interface Detector : NSObject {
  BitMatrix * image;
  BOOL compact;
  int nbLayers;
  int nbDataBlocks;
  int nbCenterLayers;
  int shift;
}

- (id) initWithImage:(BitMatrix *)image;
- (AztecDetectorResult *) detect;
@end

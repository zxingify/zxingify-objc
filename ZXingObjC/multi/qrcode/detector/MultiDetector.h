#import "NotFoundException.h"
#import "ReaderException.h"
#import "BitMatrix.h"
#import "DetectorResult.h"
#import "Detector.h"
#import "FinderPatternInfo.h"

/**
 * <p>Encapsulates logic that can detect one or more QR Codes in an image, even if the QR Code
 * is rotated or skewed, or partially obscured.</p>
 * 
 * @author Sean Owen
 * @author Hannes Erven
 */

@interface MultiDetector : Detector {
}

- (id) initWithImage:(BitMatrix *)image;
- (NSArray *) detectMulti:(NSMutableDictionary *)hints;
@end

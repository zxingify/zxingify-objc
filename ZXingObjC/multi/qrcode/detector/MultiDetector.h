#import "QRCodeDetector.h"

/**
 * <p>Encapsulates logic that can detect one or more QR Codes in an image, even if the QR Code
 * is rotated or skewed, or partially obscured.</p>
 * 
 * @author Sean Owen
 * @author Hannes Erven
 */

@class BitMatrix;

@interface MultiDetector : QRCodeDetector

- (id) initWithImage:(BitMatrix *)image;
- (NSArray *) detectMulti:(NSMutableDictionary *)hints;

@end

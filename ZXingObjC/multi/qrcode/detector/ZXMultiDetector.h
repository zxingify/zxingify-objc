#import "ZXQRCodeDetector.h"

/**
 * <p>Encapsulates logic that can detect one or more QR Codes in an image, even if the QR Code
 * is rotated or skewed, or partially obscured.</p>
 * 
 * @author Sean Owen
 * @author Hannes Erven
 */

@class ZXDecodeHints;

@interface ZXMultiDetector : ZXQRCodeDetector

- (NSArray *) detectMulti:(ZXDecodeHints *)hints;

@end

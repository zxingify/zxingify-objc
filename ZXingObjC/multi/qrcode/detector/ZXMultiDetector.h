#import "ZXQRCodeDetector.h"

/**
 * Encapsulates logic that can detect one or more QR Codes in an image, even if the QR Code
 * is rotated or skewed, or partially obscured.
 */

@class ZXDecodeHints;

@interface ZXMultiDetector : ZXQRCodeDetector

- (NSArray *)detectMulti:(ZXDecodeHints *)hints;

@end

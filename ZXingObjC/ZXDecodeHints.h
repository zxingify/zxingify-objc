#import "ZXBarcodeFormat.h"

@protocol ZXResultPointCallback;

/**
 * Encapsulates hints that a caller may pass to a barcode reader to help it
 * more quickly or accurately decode it. It is up to implementations to decide what,
 * if anything, to do with the information that is supplied.
 */
@interface ZXDecodeHints : NSObject <NSCopying>

/**
 * Assume Code 39 codes employ a check digit. Maps to {@link Boolean}.
 */
@property (nonatomic, assign) BOOL assumeCode39CheckDigit;

/**
 * Allowed lengths of encoded data -- reject anything else. Maps to an int[].
 */
@property (nonatomic, retain) NSArray* allowedLengths;

/**
 * Specifies what character encoding to use when decoding, where applicable (type String)
 */
@property (nonatomic, assign) NSStringEncoding encoding;

/**
 * Unspecified, application-specific hint.
 */
@property (nonatomic, retain) id other;

/**
 * Image is a pure monochrome image of a barcode.
 */
@property (nonatomic, assign) BOOL pureBarcode;

/**
 * The caller needs to be notified via callback when a possible {@link ResultPoint}
 * is found. Maps to a {@link ResultPointCallback}.
 */
@property (nonatomic, retain) id <ZXResultPointCallback> resultPointCallback;

/**
 * Spend more time to try to find a barcode; optimize for accuracy, not speed.
 */
@property (nonatomic, assign) BOOL tryHarder;

/**
 * Image is known to be of one of a few possible formats.
 */
- (void)addPossibleFormat:(ZXBarcodeFormat)format;
- (void)removePossibleFormat:(ZXBarcodeFormat)format;
- (BOOL)containsFormat:(ZXBarcodeFormat)format;

@end

/**
 * Encapsulates a type of hint that a caller may pass to a barcode reader to help it
 * more quickly or accurately decode it. It is up to implementations to decide what,
 * if anything, to do with the information that is supplied.
 * 
 * @author Sean Owen
 * @author dswitkin@google.com (Daniel Switkin)
 * @see Reader#decode(BinaryBitmap,java.util.Hashtable)
 */


/**
 * Unspecified, application-specific hint. Maps to an unspecified {@link Object}.
 */
extern DecodeHintType * const OTHER;

/**
 * Image is a pure monochrome image of a barcode. Doesn't matter what it maps to;
 * use {@link Boolean#TRUE}.
 */
extern DecodeHintType * const PURE_BARCODE;

/**
 * Image is known to be of one of a few possible formats.
 * Maps to a {@link java.util.Vector} of {@link BarcodeFormat}s.
 */
extern DecodeHintType * const POSSIBLE_FORMATS;

/**
 * Spend more time to try to find a barcode; optimize for accuracy, not speed.
 * Doesn't matter what it maps to; use {@link Boolean#TRUE}.
 */
extern DecodeHintType * const TRY_HARDER;

/**
 * Specifies what character encoding to use when decoding, where applicable (type String)
 */
extern DecodeHintType * const CHARACTER_SET;

/**
 * Allowed lengths of encoded data -- reject anything else. Maps to an int[].
 */
extern DecodeHintType * const ALLOWED_LENGTHS;

/**
 * Assume Code 39 codes employ a check digit. Maps to {@link Boolean}.
 */
extern DecodeHintType * const ASSUME_CODE_39_CHECK_DIGIT;

/**
 * The caller needs to be notified via callback when a possible {@link ResultPoint}
 * is found. Maps to a {@link ResultPointCallback}.
 */
extern DecodeHintType * const NEED_RESULT_POINT_CALLBACK;

@interface DecodeHintType : NSObject {
}

@end

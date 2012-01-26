
/**
 * These are a set of hints that you may pass to Writers to specify their behavior.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */


/**
 * Specifies what degree of error correction to use, for example in QR Codes (type Integer).
 */
extern EncodeHintType * const ERROR_CORRECTION;

/**
 * Specifies what character encoding to use where applicable (type String)
 */
extern EncodeHintType * const CHARACTER_SET;

@interface EncodeHintType : NSObject {
}

@end

/**
 * These are a set of hints that you may pass to Writers to specify their behavior.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */
typedef enum {
  /**
   * Specifies what degree of error correction to use, for example in QR Codes (type Integer).
   */
  kEncodeHintTypeErrorCorrection,

  /**
   * Specifies what character encoding to use where applicable (type String)
   */
  kEncodeHintTypeCharacterSet
} EncodeHintType;

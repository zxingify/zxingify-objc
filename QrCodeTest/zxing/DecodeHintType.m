#import "DecodeHintType.h"


/**
 * Unspecified, application-specific hint. Maps to an unspecified {@link Object}.
 */
DecodeHintType * const OTHER = [[[DecodeHintType alloc] init] autorelease];

/**
 * Image is a pure monochrome image of a barcode. Doesn't matter what it maps to;
 * use {@link Boolean#TRUE}.
 */
DecodeHintType * const PURE_BARCODE = [[[DecodeHintType alloc] init] autorelease];

/**
 * Image is known to be of one of a few possible formats.
 * Maps to a {@link java.util.Vector} of {@link BarcodeFormat}s.
 */
DecodeHintType * const POSSIBLE_FORMATS = [[[DecodeHintType alloc] init] autorelease];

/**
 * Spend more time to try to find a barcode; optimize for accuracy, not speed.
 * Doesn't matter what it maps to; use {@link Boolean#TRUE}.
 */
DecodeHintType * const TRY_HARDER = [[[DecodeHintType alloc] init] autorelease];

/**
 * Specifies what character encoding to use when decoding, where applicable (type String)
 */
DecodeHintType * const CHARACTER_SET = [[[DecodeHintType alloc] init] autorelease];

/**
 * Allowed lengths of encoded data -- reject anything else. Maps to an int[].
 */
DecodeHintType * const ALLOWED_LENGTHS = [[[DecodeHintType alloc] init] autorelease];

/**
 * Assume Code 39 codes employ a check digit. Maps to {@link Boolean}.
 */
DecodeHintType * const ASSUME_CODE_39_CHECK_DIGIT = [[[DecodeHintType alloc] init] autorelease];

/**
 * The caller needs to be notified via callback when a possible {@link ResultPoint}
 * is found. Maps to a {@link ResultPointCallback}.
 */
DecodeHintType * const NEED_RESULT_POINT_CALLBACK = [[[DecodeHintType alloc] init] autorelease];

@implementation DecodeHintType

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

@end

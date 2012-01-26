#import "EncodeHintType.h"


/**
 * Specifies what degree of error correction to use, for example in QR Codes (type Integer).
 */
EncodeHintType * const ERROR_CORRECTION = [[[EncodeHintType alloc] init] autorelease];

/**
 * Specifies what character encoding to use where applicable (type String)
 */
EncodeHintType * const CHARACTER_SET = [[[EncodeHintType alloc] init] autorelease];

@implementation EncodeHintType

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

@end

/**
 * Common string-related functions.
 */

@class ZXDecodeHints;

@interface ZXStringUtils : NSObject

+ (NSStringEncoding)guessEncoding:(unsigned char *)bytes length:(unsigned int)length hints:(ZXDecodeHints *)hints;

@end

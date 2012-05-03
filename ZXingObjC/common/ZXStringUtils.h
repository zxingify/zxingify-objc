/**
 * Common string-related functions.
 * 
 * @author Sean Owen
 */

@class ZXDecodeHints;

@interface ZXStringUtils : NSObject

+ (NSStringEncoding) guessEncoding:(unsigned char *)bytes length:(unsigned int)length hints:(ZXDecodeHints *)hints;

@end

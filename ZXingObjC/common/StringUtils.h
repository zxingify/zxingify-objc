/**
 * Common string-related functions.
 * 
 * @author Sean Owen
 */

@interface StringUtils : NSObject

+ (NSStringEncoding) guessEncoding:(unsigned char *)bytes length:(unsigned int)length hints:(NSMutableDictionary *)hints;

@end

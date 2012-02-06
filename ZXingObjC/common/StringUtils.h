/**
 * Common string-related functions.
 * 
 * @author Sean Owen
 */

@interface StringUtils : NSObject

+ (NSStringEncoding) guessEncoding:(char *)bytes length:(int)length hints:(NSMutableDictionary *)hints;

@end

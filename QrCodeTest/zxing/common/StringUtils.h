#import "NSMutableDictionary.h"
#import "DecodeHintType.h"

/**
 * Common string-related functions.
 * 
 * @author Sean Owen
 */

extern NSString * const SHIFT_JIS;
extern NSString * const GB2312;

@interface StringUtils : NSObject {
}

+ (NSString *) guessEncoding:(NSArray *)bytes hints:(NSMutableDictionary *)hints;
@end

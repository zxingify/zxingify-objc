/**
 * Implements Reed-Solomon enbcoding, as the name implies.
 */

@class ZXGenericGF;

@interface ZXReedSolomonEncoder : NSObject

- (id)initWithField:(ZXGenericGF *)field;
- (void)encode:(NSMutableArray *)toEncode ecBytes:(int)ecBytes;

@end

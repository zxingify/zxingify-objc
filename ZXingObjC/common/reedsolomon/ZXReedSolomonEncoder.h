/**
 * Implements Reed-Solomon enbcoding, as the name implies.
 */

@class ZXGenericGF;

@interface ZXReedSolomonEncoder : NSObject

- (id)initWithField:(ZXGenericGF *)field;
- (void)encode:(int*)toEncode toEncodeLen:(int)toEncodeLen ecBytes:(int)ecBytes;

@end

/**
 * <p>Implements Reed-Solomon enbcoding, as the name implies.</p>
 * 
 * @author Sean Owen
 * @author William Rucklidge
 */

@class ZXGenericGF;

@interface ZXReedSolomonEncoder : NSObject {
  ZXGenericGF * field;
  NSMutableArray * cachedGenerators;
}

- (id) initWithField:(ZXGenericGF *)field;
- (void) encode:(NSMutableArray *)toEncode ecBytes:(int)ecBytes;
@end

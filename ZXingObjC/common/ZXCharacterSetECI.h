#import "ZXECI.h"

/**
 * Encapsulates a Character Set ECI, according to "Extended Channel Interpretations" 5.3.1.1
 * of ISO 18004.
 * 
 * @author Sean Owen
 */

@interface ZXCharacterSetECI : ZXECI {
  NSStringEncoding encoding;
}

@property(nonatomic, readonly) NSStringEncoding encoding;

+ (ZXCharacterSetECI *) getCharacterSetECIByValue:(int)value;
+ (ZXCharacterSetECI *) getCharacterSetECIByEncoding:(NSStringEncoding)encoding;

@end

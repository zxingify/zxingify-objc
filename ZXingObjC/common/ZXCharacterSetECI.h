#import "ZXECI.h"

/**
 * Encapsulates a Character Set ECI, according to "Extended Channel Interpretations" 5.3.1.1
 * of ISO 18004.
 */

@interface ZXCharacterSetECI : ZXECI

@property (nonatomic, readonly) NSStringEncoding encoding;

+ (ZXCharacterSetECI *)characterSetECIByValue:(int)value;
+ (ZXCharacterSetECI *)characterSetECIByEncoding:(NSStringEncoding)encoding;

@end

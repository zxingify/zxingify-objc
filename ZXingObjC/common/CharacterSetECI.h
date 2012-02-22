#import "ECI.h"

/**
 * Encapsulates a Character Set ECI, according to "Extended Channel Interpretations" 5.3.1.1
 * of ISO 18004.
 * 
 * @author Sean Owen
 */

@interface CharacterSetECI : ECI {
  NSStringEncoding encoding;
}

@property(nonatomic, readonly) NSStringEncoding encoding;

+ (CharacterSetECI *) getCharacterSetECIByValue:(int)value;
+ (CharacterSetECI *) getCharacterSetECIByEncoding:(NSStringEncoding)encoding;

@end

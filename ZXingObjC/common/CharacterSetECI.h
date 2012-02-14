#import "ECI.h"

/**
 * Encapsulates a Character Set ECI, according to "Extended Channel Interpretations" 5.3.1.1
 * of ISO 18004.
 * 
 * @author Sean Owen
 */

@interface CharacterSetECI : ECI {
  NSString* encoding;
}

@property(nonatomic, readonly) NSString* encoding;

+ (CharacterSetECI *) getCharacterSetECIByValue:(int)value;
+ (CharacterSetECI *) getCharacterSetECIByName:(NSString *)name;

@end

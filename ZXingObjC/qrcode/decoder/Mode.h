
/**
 * <p>See ISO 18004:2006, 6.4.1, Tables 2 and 3. This enum encapsulates the various modes in which
 * data can be encoded to bits in the QR code standard.</p>
 * 
 * @author Sean Owen
 */

extern Mode * const TERMINATOR;
extern Mode * const NUMERIC;
extern Mode * const ALPHANUMERIC;
extern Mode * const STRUCTURED_APPEND;
extern Mode * const BYTE;
extern Mode * const ECI;
extern Mode * const KANJI;
extern Mode * const FNC1_FIRST_POSITION;
extern Mode * const FNC1_SECOND_POSITION;

/**
 * See GBT 18284-2000; "Hanzi" is a transliteration of this mode name.
 */
extern Mode * const HANZI;

@interface Mode : NSObject {
  NSArray * characterCountBitsForVersions;
  int bits;
  NSString * name;
}

@property(nonatomic, readonly) int bits;
@property(nonatomic, retain, readonly) NSString * name;
+ (Mode *) forBits:(int)bits;
- (int) getCharacterCountBits:(Version *)version;
- (NSString *) description;
@end

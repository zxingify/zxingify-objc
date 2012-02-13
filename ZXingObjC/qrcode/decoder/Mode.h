/**
 * <p>See ISO 18004:2006, 6.4.1, Tables 2 and 3. This enum encapsulates the various modes in which
 * data can be encoded to bits in the QR code standard.</p>
 * 
 * @author Sean Owen
 */

@class QRCodeVersion;

@interface Mode : NSObject {
  NSArray * characterCountBitsForVersions;
  int bits;
  NSString * name;
}

@property(nonatomic, readonly) int bits;
@property(nonatomic, retain, readonly) NSString * name;

- (id)initWithCharacterCountBitsForVersions:(NSArray *)characterCountBitsForVersions
                                       bits:(int)bits
                                       name:(NSString *)name;
+ (Mode *) forBits:(int)bits;
- (int) getCharacterCountBits:(QRCodeVersion *)version;

+ (Mode *)terminatorMode; // Not really a mode...
+ (Mode *)numericMode;
+ (Mode *)alphanumericMode;
+ (Mode *)structuredAppendMode; // Not supported
+ (Mode *)byteMode;
+ (Mode *)eciMode; // character counts don't apply
+ (Mode *)kanjiMode;
+ (Mode *)fnc1FirstPositionMode;
+ (Mode *)fnc1SecondPositionMode;

/** See GBT 18284-2000; "Hanzi" is a transliteration of this mode name. */
+ (Mode *)hanziMode;

@end

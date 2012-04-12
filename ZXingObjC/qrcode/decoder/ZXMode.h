/**
 * <p>See ISO 18004:2006, 6.4.1, Tables 2 and 3. This enum encapsulates the various modes in which
 * data can be encoded to bits in the QR code standard.</p>
 * 
 * @author Sean Owen
 */

@class ZXQRCodeVersion;

@interface ZXMode : NSObject {
  NSArray * characterCountBitsForVersions;
  int bits;
  NSString * name;
}

@property(nonatomic, readonly) int bits;
@property(nonatomic, retain, readonly) NSString * name;

- (id)initWithCharacterCountBitsForVersions:(NSArray *)characterCountBitsForVersions
                                       bits:(int)bits
                                       name:(NSString *)name;
+ (ZXMode *) forBits:(int)bits;
- (int) getCharacterCountBits:(ZXQRCodeVersion *)version;

+ (ZXMode *)terminatorMode; // Not really a mode...
+ (ZXMode *)numericMode;
+ (ZXMode *)alphanumericMode;
+ (ZXMode *)structuredAppendMode; // Not supported
+ (ZXMode *)byteMode;
+ (ZXMode *)eciMode; // character counts don't apply
+ (ZXMode *)kanjiMode;
+ (ZXMode *)fnc1FirstPositionMode;
+ (ZXMode *)fnc1SecondPositionMode;

/** See GBT 18284-2000; "Hanzi" is a transliteration of this mode name. */
+ (ZXMode *)hanziMode;

@end

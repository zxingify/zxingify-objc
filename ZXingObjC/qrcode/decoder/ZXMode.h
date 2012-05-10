/**
 * See ISO 18004:2006, 6.4.1, Tables 2 and 3. This enum encapsulates the various modes in which
 * data can be encoded to bits in the QR code standard.
 */

@class ZXQRCodeVersion;

@interface ZXMode : NSObject

@property (nonatomic, assign, readonly) int bits;
@property (nonatomic, copy, readonly) NSString * name;

- (id)initWithCharacterCountBitsForVersions:(NSArray *)characterCountBitsForVersions
                                       bits:(int)bits
                                       name:(NSString *)name;
+ (ZXMode *)forBits:(int)bits;
- (int)characterCountBits:(ZXQRCodeVersion *)version;

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

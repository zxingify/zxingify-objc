/**
 * <p>See ISO 18004:2006, 6.5.1. This enum encapsulates the four error correction levels
 * defined by the QR code standard.</p>
 * 
 * @author Sean Owen
 */

@interface ZXErrorCorrectionLevel : NSObject {
  int ordinal;
  int bits;
  NSString *name;
}

@property(nonatomic, readonly) int bits;
@property(nonatomic, retain, readonly) NSString *name;

- (id)initWithOrdinal:(int)anOrdinal bits:(int)theBits name:(NSString *)aName;
- (int)ordinal;
- (NSString *)description;
+ (ZXErrorCorrectionLevel *)forBits:(int)bits;

/**
 * L = ~7% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelL;

/**
 * M = ~15% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelM;

/**
 * Q = ~25% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelQ;

/**
 * H = ~30% correction
 */
+ (ZXErrorCorrectionLevel *)errorCorrectionLevelH;

@end

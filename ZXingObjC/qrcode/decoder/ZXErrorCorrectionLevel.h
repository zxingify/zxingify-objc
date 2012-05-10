/**
 * See ISO 18004:2006, 6.5.1. This enum encapsulates the four error correction levels
 * defined by the QR code standard.
 */

@interface ZXErrorCorrectionLevel : NSObject

@property (nonatomic, assign, readonly) int bits;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) int ordinal;

- (id)initWithOrdinal:(int)anOrdinal bits:(int)theBits name:(NSString *)aName;
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

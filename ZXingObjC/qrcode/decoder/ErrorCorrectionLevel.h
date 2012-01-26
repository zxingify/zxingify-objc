
/**
 * <p>See ISO 18004:2006, 6.5.1. This enum encapsulates the four error correction levels
 * defined by the QR code standard.</p>
 * 
 * @author Sean Owen
 */


/**
 * L = ~7% correction
 */
extern ErrorCorrectionLevel * const L;

/**
 * M = ~15% correction
 */
extern ErrorCorrectionLevel * const M;

/**
 * Q = ~25% correction
 */
extern ErrorCorrectionLevel * const Q;

/**
 * H = ~30% correction
 */
extern ErrorCorrectionLevel * const H;

@interface ErrorCorrectionLevel : NSObject {
  int ordinal;
  int bits;
  NSString * name;
}

@property(nonatomic, readonly) int bits;
@property(nonatomic, retain, readonly) NSString * name;
- (int) ordinal;
- (NSString *) description;
+ (ErrorCorrectionLevel *) forBits:(int)bits;
@end

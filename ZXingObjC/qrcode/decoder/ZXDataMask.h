/**
 * <p>Encapsulates data masks for the data bits in a QR code, per ISO 18004:2006 6.8. Implementations
 * of this class can un-mask a raw BitMatrix. For simplicity, they will unmask the entire BitMatrix,
 * including areas used for finder patterns, timing patterns, etc. These areas should be unused
 * after the point they are unmasked anyway.</p>
 * 
 * <p>Note that the diagram in section 6.8.1 is misleading since it indicates that i is column position
 * and j is row position. In fact, as the text says, i is row position and j is column position.</p>
 * 
 * @author Sean Owen
 */

@class ZXBitMatrix;

@interface ZXDataMask : NSObject

- (void) unmaskBitMatrix:(ZXBitMatrix *)bits dimension:(int)dimension;
- (BOOL) isMasked:(int)i j:(int)j;
+ (ZXDataMask *) forReference:(int)reference;

@end

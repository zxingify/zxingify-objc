#import "BitMatrix.h"
#import "DataMask.h"

@interface DataMask : NSObject {
}

- (void) unmaskBitMatrix:(BitMatrix *)bits dimension:(int)dimension;
- (BOOL) isMasked:(int)i j:(int)j;
+ (DataMask *) forReference:(int)reference;
@end

/**
 * 000: mask bits for which (x + y) mod 2 == 0
 */

@interface DataMask000 : DataMask {
}

- (BOOL) isMasked:(int)i j:(int)j;
@end

/**
 * 001: mask bits for which x mod 2 == 0
 */

@interface DataMask001 : DataMask {
}

- (BOOL) isMasked:(int)i j:(int)j;
@end

/**
 * 010: mask bits for which y mod 3 == 0
 */

@interface DataMask010 : DataMask {
}

- (BOOL) isMasked:(int)i j:(int)j;
@end

/**
 * 011: mask bits for which (x + y) mod 3 == 0
 */

@interface DataMask011 : DataMask {
}

- (BOOL) isMasked:(int)i j:(int)j;
@end

/**
 * 100: mask bits for which (x/2 + y/3) mod 2 == 0
 */

@interface DataMask100 : DataMask {
}

- (BOOL) isMasked:(int)i j:(int)j;
@end

/**
 * 101: mask bits for which xy mod 2 + xy mod 3 == 0
 */

@interface DataMask101 : DataMask {
}

- (BOOL) isMasked:(int)i j:(int)j;
@end

/**
 * 110: mask bits for which (xy mod 2 + xy mod 3) mod 2 == 0
 */

@interface DataMask110 : DataMask {
}

- (BOOL) isMasked:(int)i j:(int)j;
@end

/**
 * 111: mask bits for which ((x+y)mod 2 + xy mod 3) mod 2 == 0
 */

@interface DataMask111 : DataMask {
}

- (BOOL) isMasked:(int)i j:(int)j;
@end

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


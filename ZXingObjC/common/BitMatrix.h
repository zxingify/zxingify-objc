#import "BitArray.h"

/**
 * <p>Represents a 2D matrix of bits. In function arguments below, and throughout the common
 * module, x is the column position, and y is the row position. The ordering is always x, y.
 * The origin is at the top-left.</p>
 * 
 * <p>Internally the bits are represented in a 1-D array of 32-bit ints. However, each row begins
 * with a new int. This is done intentionally so that we can copy out a row into a BitArray very
 * efficiently.</p>
 * 
 * <p>The ordering of bits is row-major. Within each int, the least significant bits are used first,
 * meaning they represent lower x values. This is compatible with BitArray's implementation.</p>
 * 
 * @author Sean Owen
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface BitMatrix : NSObject {
  int width;
  int height;
  int rowSize;
  NSArray * bits;
}

@property(nonatomic, retain, readonly) NSArray * topLeftOnBit;
@property(nonatomic, retain, readonly) NSArray * bottomRightOnBit;
@property(nonatomic, readonly) int width;
@property(nonatomic, readonly) int height;
- (id) initWithDimension:(int)dimension;
- (id) init:(int)width height:(int)height;
- (BOOL) get:(int)x y:(int)y;
- (void) set:(int)x y:(int)y;
- (void) flip:(int)x y:(int)y;
- (void) clear;
- (void) setRegion:(int)left top:(int)top width:(int)width height:(int)height;
- (BitArray *) getRow:(int)y row:(BitArray *)row;
- (BOOL) isEqualTo:(NSObject *)o;
- (int) hash;
- (NSString *) description;
@end

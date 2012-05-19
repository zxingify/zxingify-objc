/**
 * Represents a 2D matrix of bits. In function arguments below, and throughout the common
 * module, x is the column position, and y is the row position. The ordering is always x, y.
 * The origin is at the top-left.
 * 
 * Internally the bits are represented in a 1-D array of 32-bit ints. However, each row begins
 * with a new int. This is done intentionally so that we can copy out a row into a BitArray very
 * efficiently.
 * 
 * The ordering of bits is row-major. Within each int, the least significant bits are used first,
 * meaning they represent lower x values. This is compatible with BitArray's implementation.
 */

@class ZXBitArray;

@interface ZXBitMatrix : NSObject

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;
@property (nonatomic, readonly) int* bits;

- (id)initWithDimension:(int)dimension;
- (id)initWithWidth:(int)width height:(int)height;

- (BOOL)getX:(int)x y:(int)y;
- (void)setX:(int)x y:(int)y;
- (void)flipX:(int)x y:(int)y;
- (void)clear;
- (void)setRegionAtLeft:(int)left top:(int)top width:(int)width height:(int)height;
- (ZXBitArray *)rowAtY:(int)y row:(ZXBitArray *)row;
- (NSArray *)topLeftOnBit;
- (NSArray *)bottomRightOnBit;

@end

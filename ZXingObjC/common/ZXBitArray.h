/**
 * A simple, fast array of bits, represented compactly by an array of ints internally.
 */

@interface ZXBitArray : NSObject

@property (nonatomic, readonly) int size;
@property (nonatomic, readonly) int* bits;

- (id)initWithSize:(int)size;
- (int)sizeInBytes;
- (BOOL)get:(int)i;
- (void)set:(int)i;
- (void)flip:(int)i;
- (void)setBulk:(int)i newBits:(int)newBits;
- (void)clear;
- (BOOL)isRange:(int)start end:(int)end value:(BOOL)value;
- (void)appendBit:(BOOL)bit;
- (void)appendBits:(int)value numBits:(int)numBits;
- (void)appendBitArray:(ZXBitArray *)other;
- (void)xor:(ZXBitArray *)other;
- (void)toBytes:(int)bitOffset array:(unsigned char *)array offset:(int)offset numBytes:(int)numBytes;
- (void)reverse;

@end

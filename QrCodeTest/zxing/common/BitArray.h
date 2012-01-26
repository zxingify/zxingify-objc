
/**
 * <p>A simple, fast array of bits, represented compactly by an array of ints internally.</p>
 * 
 * @author Sean Owen
 */

@interface BitArray : NSObject {
  NSArray * bits;
  int size;
}

@property(nonatomic, readonly) int size;
@property(nonatomic, readonly) int sizeInBytes;
@property(nonatomic, retain, readonly) NSArray * bitArray;
- (id) init;
- (id) initWithSize:(int)size;
- (BOOL) get:(int)i;
- (void) set:(int)i;
- (void) flip:(int)i;
- (void) setBulk:(int)i newBits:(int)newBits;
- (void) clear;
- (BOOL) isRange:(int)start end:(int)end value:(BOOL)value;
- (void) appendBit:(BOOL)bit;
- (void) appendBits:(int)value numBits:(int)numBits;
- (void) appendBitArray:(BitArray *)other;
- (void) xor:(BitArray *)other;
- (void) toBytes:(int)bitOffset array:(NSArray *)array offset:(int)offset numBytes:(int)numBytes;
- (void) reverse;
- (NSString *) description;
@end

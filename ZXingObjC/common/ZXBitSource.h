/**
 * This provides an easy abstraction to read bits at a time from a sequence of bytes, where the
 * number of bits read is not often a multiple of 8.
 * 
 * This class is thread-safe but not reentrant. Unless the caller modifies the bytes array
 * it passed in, in which case all bets are off.
 */

@interface ZXBitSource : NSObject

- (id)initWithBytes:(unsigned char *)bytes length:(unsigned int)length;
- (int)readBits:(int)numBits;
- (int)available;

@end

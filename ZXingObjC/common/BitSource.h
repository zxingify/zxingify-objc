
/**
 * <p>This provides an easy abstraction to read bits at a time from a sequence of bytes, where the
 * number of bits read is not often a multiple of 8.</p>
 * 
 * <p>This class is thread-safe but not reentrant. Unless the caller modifies the bytes array
 * it passed in, in which case all bets are off.</p>
 * 
 * @author Sean Owen
 */

@interface BitSource : NSObject {
  char * bytes;
  int byteOffset;
  int bitOffset;
}

- (id) initWithBytes:(char *)bytes;
- (int) readBits:(int)numBits;
- (int) available;

@end

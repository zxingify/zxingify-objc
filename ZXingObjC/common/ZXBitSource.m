#import "ZXBitSource.h"

@implementation ZXBitSource


/**
 * @param bytes bytes from which this will read bits. Bits will be read from the first byte first.
 * Bits are read within a byte from most-significant to least-significant bit.
 */
- (id) initWithBytes:(unsigned char *)aBytes length:(unsigned int)aLength {
  if (self = [super init]) {
    bytes = aBytes;
    length = aLength;
  }
  return self;
}


/**
 * @param numBits number of bits to read
 * @return int representing the bits read. The bits will appear as the least-significant
 * bits of the int
 * @throws IllegalArgumentException if numBits isn't in [1,32]
 */
- (int) readBits:(int)numBits {
  if (numBits < 1 || numBits > 32) {
    [NSException raise:NSInvalidArgumentException 
                format:@"Number of bits must be between 1 and 32."];
  }
  int result = 0;
  if (bitOffset > 0) {
    int bitsLeft = 8 - bitOffset;
    int toRead = numBits < bitsLeft ? numBits : bitsLeft;
    int bitsToNotRead = bitsLeft - toRead;
    int mask = (0xFF >> (8 - toRead)) << bitsToNotRead;
    result = (bytes[byteOffset] & mask) >> bitsToNotRead;
    numBits -= toRead;
    bitOffset += toRead;
    if (bitOffset == 8) {
      bitOffset = 0;
      byteOffset++;
    }
  }
  if (numBits > 0) {

    while (numBits >= 8) {
      result = (result << 8) | (bytes[byteOffset] & 0xFF);
      byteOffset++;
      numBits -= 8;
    }

    if (numBits > 0) {
      int bitsToNotRead = 8 - numBits;
      int mask = (0xFF >> bitsToNotRead) << bitsToNotRead;
      result = (result << numBits) | ((bytes[byteOffset] & mask) >> bitsToNotRead);
      bitOffset += numBits;
    }
  }
  return result;
}


/**
 * @return number of bits that can be read successfully
 */
- (int) available {
  return 8 * (length - byteOffset) - bitOffset;
}

@end

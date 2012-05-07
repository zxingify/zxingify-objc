#import "ZXBitSource.h"

@interface ZXBitSource ()

@property (nonatomic, assign) unsigned char * bytes;
@property (nonatomic, assign) int byteOffset;
@property (nonatomic, assign) int bitOffset;
@property (nonatomic, assign) int length;

@end

@implementation ZXBitSource

@synthesize bytes;
@synthesize byteOffset;
@synthesize bitOffset;
@synthesize length;

/**
 * bytes is the bytes from which this will read bits. Bits will be read from the first byte first.
 * Bits are read within a byte from most-significant to least-significant bit.
 */
- (id)initWithBytes:(unsigned char *)aBytes length:(unsigned int)aLength {
  if (self = [super init]) {
    self.bytes = aBytes;
    self.length = aLength;
  }
  return self;
}


- (int)readBits:(int)numBits {
  if (numBits < 1 || numBits > 32) {
    [NSException raise:NSInvalidArgumentException 
                format:@"Number of bits must be between 1 and 32."];
  }
  int result = 0;
  if (self.bitOffset > 0) {
    int bitsLeft = 8 - self.bitOffset;
    int toRead = numBits < bitsLeft ? numBits : bitsLeft;
    int bitsToNotRead = bitsLeft - toRead;
    int mask = (0xFF >> (8 - toRead)) << bitsToNotRead;
    result = (self.bytes[self.byteOffset] & mask) >> bitsToNotRead;
    numBits -= toRead;
    self.bitOffset += toRead;
    if (self.bitOffset == 8) {
      self.bitOffset = 0;
      self.byteOffset++;
    }
  }

  if (numBits > 0) {
    while (numBits >= 8) {
      result = (result << 8) | (self.bytes[self.byteOffset] & 0xFF);
      self.byteOffset++;
      numBits -= 8;
    }

    if (numBits > 0) {
      int bitsToNotRead = 8 - numBits;
      int mask = (0xFF >> bitsToNotRead) << bitsToNotRead;
      result = (result << numBits) | ((self.bytes[self.byteOffset] & mask) >> bitsToNotRead);
      self.bitOffset += numBits;
    }
  }
  return result;
}

- (int)available {
  return 8 * (self.length - self.byteOffset) - self.bitOffset;
}

@end

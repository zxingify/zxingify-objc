#import "ZXBitSourceBuilder.h"

@interface ZXBitSourceBuilder ()

@property (nonatomic, assign) int bitsLeftInNextByte;
@property (nonatomic, assign) int nextByte;
@property (nonatomic, retain) NSMutableData* output;

@end


/**
 * Class that lets one easily build an array of bytes by appending bits at a time.
 */
@implementation ZXBitSourceBuilder

@synthesize bitsLeftInNextByte;
@synthesize nextByte;
@synthesize output;

- (id)init {
  if(self = [super init]) {
    self.bitsLeftInNextByte = 8;
    self.nextByte = 0;
    self.output = [NSMutableData data];
  }

  return self;
}

- (void)write:(int)value numBits:(int)numBits {
  if (numBits <= self.bitsLeftInNextByte) {
    self.nextByte <<= numBits;
    self.nextByte |= value;
    self.bitsLeftInNextByte -= numBits;
    if (self.bitsLeftInNextByte == 0) {
      [self.output appendBytes:&nextByte length:1];
      self.nextByte = 0;
      self.bitsLeftInNextByte = 8;
    }
  } else {
    int bitsToWriteNow = self.bitsLeftInNextByte;
    int numRestOfBits = numBits - bitsToWriteNow;
    int mask = 0xFF >> (8 - bitsToWriteNow);
    int valueToWriteNow = (int)(((unsigned int)value) >> numRestOfBits) & mask;
    [self write:valueToWriteNow numBits:bitsToWriteNow];
    [self write:value numBits:numRestOfBits];
  }
}

- (unsigned char*)toByteArray {
  if (self.bitsLeftInNextByte < 8) {
    [self write:0 numBits:self.bitsLeftInNextByte];
  }
  return (unsigned char*)[self.output bytes];
}

- (int)byteArrayLength {
  return [self.output length];
}

@end

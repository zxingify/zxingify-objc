#import "BitMatrix.h"

@implementation BitMatrix

@synthesize topLeftOnBit;
@synthesize bottomRightOnBit;
@synthesize width;
@synthesize height;

- (id) initWithDimension:(int)dimension {
  if (self = [self init:dimension height:dimension]) {
  }
  return self;
}

- (id) init:(int)width height:(int)height {
  if (self = [super init]) {
    if (width < 1 || height < 1) {
      @throw [[[IllegalArgumentException alloc] init:@"Both dimensions must be greater than 0"] autorelease];
    }
    width = width;
    height = height;
    rowSize = (width + 31) >> 5;
    bits = [NSArray array];
  }
  return self;
}


/**
 * <p>Gets the requested bit, where true means black.</p>
 * 
 * @param x The horizontal component (i.e. which column)
 * @param y The vertical component (i.e. which row)
 * @return value of given bit in matrix
 */
- (BOOL) get:(int)x y:(int)y {
  int offset = y * rowSize + (x >> 5);
  return ((bits[offset] >>> (x & 0x1f)) & 1) != 0;
}


/**
 * <p>Sets the given bit to true.</p>
 * 
 * @param x The horizontal component (i.e. which column)
 * @param y The vertical component (i.e. which row)
 */
- (void) set:(int)x y:(int)y {
  int offset = y * rowSize + (x >> 5);
  bits[offset] |= 1 << (x & 0x1f);
}


/**
 * <p>Flips the given bit.</p>
 * 
 * @param x The horizontal component (i.e. which column)
 * @param y The vertical component (i.e. which row)
 */
- (void) flip:(int)x y:(int)y {
  int offset = y * rowSize + (x >> 5);
  bits[offset] ^= 1 << (x & 0x1f);
}


/**
 * Clears all bits (sets to false).
 */
- (void) clear {
  int max = bits.length;

  for (int i = 0; i < max; i++) {
    bits[i] = 0;
  }

}


/**
 * <p>Sets a square region of the bit matrix to true.</p>
 * 
 * @param left The horizontal position to begin at (inclusive)
 * @param top The vertical position to begin at (inclusive)
 * @param width The width of the region
 * @param height The height of the region
 */
- (void) setRegion:(int)left top:(int)top width:(int)width height:(int)height {
  if (top < 0 || left < 0) {
    @throw [[[IllegalArgumentException alloc] init:@"Left and top must be nonnegative"] autorelease];
  }
  if (height < 1 || width < 1) {
    @throw [[[IllegalArgumentException alloc] init:@"Height and width must be at least 1"] autorelease];
  }
  int right = left + width;
  int bottom = top + height;
  if (bottom > height || right > width) {
    @throw [[[IllegalArgumentException alloc] init:@"The region must fit inside the matrix"] autorelease];
  }

  for (int y = top; y < bottom; y++) {
    int offset = y * rowSize;

    for (int x = left; x < right; x++) {
      bits[offset + (x >> 5)] |= 1 << (x & 0x1f);
    }

  }

}


/**
 * A fast method to retrieve one row of data from the matrix as a BitArray.
 * 
 * @param y The row to retrieve
 * @param row An optional caller-allocated BitArray, will be allocated if null or too small
 * @return The resulting BitArray - this reference should always be used even when passing
 * your own row
 */
- (BitArray *) getRow:(int)y row:(BitArray *)row {
  if (row == nil || [row size] < width) {
    row = [[[BitArray alloc] init:width] autorelease];
  }
  int offset = y * rowSize;

  for (int x = 0; x < rowSize; x++) {
    [row setBulk:x << 5 param1:bits[offset + x]];
  }

  return row;
}


/**
 * This is useful in detecting a corner of a 'pure' barcode.
 * 
 * @return {x,y} coordinate of top-left-most 1 bit, or null if it is all white
 */
- (NSArray *) topLeftOnBit {
  int bitsOffset = 0;

  while (bitsOffset < bits.length && bits[bitsOffset] == 0) {
    bitsOffset++;
  }

  if (bitsOffset == bits.length) {
    return nil;
  }
  int y = bitsOffset / rowSize;
  int x = (bitsOffset % rowSize) << 5;
  int theBits = bits[bitsOffset];
  int bit = 0;

  while ((theBits << (31 - bit)) == 0) {
    bit++;
  }

  x += bit;
  return [NSArray arrayWithObjects:x, y, nil];
}

- (NSArray *) bottomRightOnBit {
  int bitsOffset = bits.length - 1;

  while (bitsOffset >= 0 && bits[bitsOffset] == 0) {
    bitsOffset--;
  }

  if (bitsOffset < 0) {
    return nil;
  }
  int y = bitsOffset / rowSize;
  int x = (bitsOffset % rowSize) << 5;
  int theBits = bits[bitsOffset];
  int bit = 31;

  while ((theBits >>> bit) == 0) {
    bit--;
  }

  x += bit;
  return [NSArray arrayWithObjects:x, y, nil];
}

- (BOOL) isEqualTo:(NSObject *)o {
  if (!([o conformsToProtocol:@protocol(BitMatrix)])) {
    return NO;
  }
  BitMatrix * other = (BitMatrix *)o;
  if (width != other.width || height != other.height || rowSize != other.rowSize || bits.length != other.bits.length) {
    return NO;
  }

  for (int i = 0; i < bits.length; i++) {
    if (bits[i] != other.bits[i]) {
      return NO;
    }
  }

  return YES;
}

- (int) hash {
  int hash = width;
  hash = 31 * hash + width;
  hash = 31 * hash + height;
  hash = 31 * hash + rowSize;

  for (int i = 0; i < bits.length; i++) {
    hash = 31 * hash + bits[i];
  }

  return hash;
}

- (NSString *) description {
  StringBuffer * result = [[[StringBuffer alloc] init:height * (width + 1)] autorelease];

  for (int y = 0; y < height; y++) {

    for (int x = 0; x < width; x++) {
      [result append:[self get:x y:y] ? @"X " : @"  "];
    }

    [result append:'\n'];
  }

  return [result description];
}

- (void) dealloc {
  [bits release];
  [super dealloc];
}

@end

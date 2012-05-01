#import "ZXBitArray.h"
#import "ZXBitMatrix.h"

@implementation ZXBitMatrix

@synthesize topLeftOnBit;
@synthesize bottomRightOnBit;
@synthesize width;
@synthesize height;
@synthesize bits;

- (oneway void) release {
  [super release];
}

- (id)retain {
  return [super retain];
}

- (id) initWithDimension:(int)dimension {
  self = [self initWithWidth:dimension height:dimension];
  return self;
}

- (id) initWithWidth:(int)aWidth height:(int)aHeight {
  if (self = [super init]) {
    if (aWidth < 1 || aHeight < 1) {
      @throw [NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Both dimensions must be greater than 0"
                                   userInfo:nil];
    }
    width = aWidth;
    height = aHeight;
    rowSize = (width + 31) >> 5;
    bitsSize = rowSize * height;
    bits = (int*)malloc(bitsSize * sizeof(int));
    [self clear];
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
  return ((int)((unsigned int)bits[offset] >> (x & 0x1f)) & 1) != 0;
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
  int max = bitsSize;

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
- (void) setRegion:(int)left top:(int)top width:(int)aWidth height:(int)aHeight {
  if (top < 0 || left < 0) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Left and top must be nonnegative"
                                 userInfo:nil];
  }
  if (aHeight < 1 || aWidth < 1) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"Height and width must be at least 1"
                                 userInfo:nil];
  }
  int right = left + aWidth;
  int bottom = top + aHeight;
  if (bottom > self.height || right > self.width) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"The region must fit inside the matrix"
                                 userInfo:nil];
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
- (ZXBitArray *) getRow:(int)y row:(ZXBitArray *)row {
  if (row == nil || [row size] < width) {
    row = [[[ZXBitArray alloc] initWithSize:width] autorelease];
  }
  int offset = y * rowSize;
  for (int x = 0; x < rowSize; x++) {
    [row setBulk:x << 5 newBits:bits[offset + x]];
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
  while (bitsOffset < bitsSize && bits[bitsOffset] == 0) {
    bitsOffset++;
  }
  if (bitsOffset == bitsSize) {
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
  return [NSArray arrayWithObjects:[NSNumber numberWithInt:x], [NSNumber numberWithInt:y], nil];
}

- (NSArray *) bottomRightOnBit {
  int bitsOffset = bitsSize - 1;
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
  while ((int)((unsigned int)theBits >> bit) == 0) {
    bit--;
  }
  x += bit;

  return [NSArray arrayWithObjects:[NSNumber numberWithInt:x], [NSNumber numberWithInt:y], nil];
}

- (BOOL) isEqualTo:(NSObject *)o {
  if (!([o isKindOfClass:[ZXBitMatrix class]])) {
    return NO;
  }
  ZXBitMatrix * other = (ZXBitMatrix *)o;
  if (width != other.width || height != other.height || rowSize != other->rowSize || bitsSize != other->bitsSize) {
    return NO;
  }
  for (int i = 0; i < bitsSize; i++) {
    if (bits[i] != other->bits[i]) {
      return NO;
    }
  }
  return YES;
}

- (NSUInteger) hash {
  int hash = width;
  hash = 31 * hash + width;
  hash = 31 * hash + height;
  hash = 31 * hash + rowSize;
  for (int i = 0; i < bitsSize; i++) {
    hash = 31 * hash + bits[i];
  }
  return hash;
}

- (NSString *) description {
  NSMutableString * result = [NSMutableString stringWithCapacity:height * (width + 1)];
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      [result appendString:[self get:x y:y] ? @"X " : @"  "];
    }
    [result appendString:@"\n"];
  }
  return result;
}

- (void) dealloc {
  free(bits);
  [super dealloc];
}

@end

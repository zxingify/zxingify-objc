#import "ZXBitArray.h"
#import "ZXBitMatrix.h"

@interface ZXBitMatrix ()

@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic) int* bits;
@property (nonatomic) int rowSize;
@property (nonatomic) int bitsSize;

@end

@implementation ZXBitMatrix

@synthesize width;
@synthesize height;
@synthesize bits;
@synthesize rowSize;
@synthesize bitsSize;

- (id)initWithDimension:(int)dimension {
  return [self initWithWidth:dimension height:dimension];
}

- (id)initWithWidth:(int)aWidth height:(int)aHeight {
  self = [super init];
  if (self) {
    if (aWidth < 1 || aHeight < 1) {
      @throw [NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Both dimensions must be greater than 0"
                                   userInfo:nil];
    }
    self.width = aWidth;
    self.height = aHeight;
    self.rowSize = (self.width + 31) >> 5;
    self.bitsSize = self.rowSize * self.height;
    self.bits = (int*)malloc(self.bitsSize * sizeof(int));
    [self clear];
  }

  return self;
}

- (void) dealloc {
  if (bits != NULL) {
    free(bits);
    bits = NULL;
  }

  [super dealloc];
}

/**
 * Gets the requested bit, where true means black.
 */
- (BOOL)get:(int)x y:(int)y {
  int offset = y * self.rowSize + (x >> 5);
  return ((int)((unsigned int)self.bits[offset] >> (x & 0x1f)) & 1) != 0;
}

/**
 * Sets the given bit to true.
 */
- (void)set:(int)x y:(int)y {
  int offset = y * self.rowSize + (x >> 5);
  self.bits[offset] |= 1 << (x & 0x1f);
}


/**
 * Flips the given bit.
 */
- (void)flip:(int)x y:(int)y {
  int offset = y * self.rowSize + (x >> 5);
  self.bits[offset] ^= 1 << (x & 0x1f);
}


/**
 * Clears all bits (sets to false).
 */
- (void) clear {
  int max = self.bitsSize;

  for (int i = 0; i < max; i++) {
    self.bits[i] = 0;
  }
}


/**
 * Sets a square region of the bit matrix to true.
 */
- (void)setRegion:(int)left top:(int)top width:(int)aWidth height:(int)aHeight {
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
    int offset = y * self.rowSize;
    for (int x = left; x < right; x++) {
      self.bits[offset + (x >> 5)] |= 1 << (x & 0x1f);
    }
  }
}


/**
 * A fast method to retrieve one row of data from the matrix as a BitArray.
 */
- (ZXBitArray *)row:(int)y row:(ZXBitArray *)row {
  if (row == nil || [row size] < self.width) {
    row = [[[ZXBitArray alloc] initWithSize:self.width] autorelease];
  }
  int offset = y * self.rowSize;
  for (int x = 0; x < self.rowSize; x++) {
    [row setBulk:x << 5 newBits:self.bits[offset + x]];
  }

  return row;
}


/**
 * This is useful in detecting a corner of a 'pure' barcode.
 * 
 * Returns {x,y} coordinate of top-left-most 1 bit, or null if it is all white
 */
- (NSArray *) topLeftOnBit {
  int bitsOffset = 0;
  while (bitsOffset < self.bitsSize && self.bits[bitsOffset] == 0) {
    bitsOffset++;
  }
  if (bitsOffset == self.bitsSize) {
    return nil;
  }
  int y = bitsOffset / self.rowSize;
  int x = (bitsOffset % self.rowSize) << 5;

  int theBits = self.bits[bitsOffset];
  int bit = 0;
  while ((theBits << (31 - bit)) == 0) {
    bit++;
  }
  x += bit;
  return [NSArray arrayWithObjects:[NSNumber numberWithInt:x], [NSNumber numberWithInt:y], nil];
}

- (NSArray *) bottomRightOnBit {
  int bitsOffset = self.bitsSize - 1;
  while (bitsOffset >= 0 && self.bits[bitsOffset] == 0) {
    bitsOffset--;
  }
  if (bitsOffset < 0) {
    return nil;
  }

  int y = bitsOffset / self.rowSize;
  int x = (bitsOffset % self.rowSize) << 5;

  int theBits = self.bits[bitsOffset];
  int bit = 31;
  while ((int)((unsigned int)theBits >> bit) == 0) {
    bit--;
  }
  x += bit;

  return [NSArray arrayWithObjects:[NSNumber numberWithInt:x], [NSNumber numberWithInt:y], nil];
}

- (BOOL)isEqual:(NSObject *)o {
  if (!([o isKindOfClass:[ZXBitMatrix class]])) {
    return NO;
  }
  ZXBitMatrix * other = (ZXBitMatrix *)o;
  if (self.width != other.width || self.height != other.height || self.rowSize != other->rowSize || self.bitsSize != other->bitsSize) {
    return NO;
  }
  for (int i = 0; i < self.bitsSize; i++) {
    if (self.bits[i] != other->bits[i]) {
      return NO;
    }
  }
  return YES;
}

- (NSUInteger)hash {
  int hash = self.width;
  hash = 31 * hash + self.width;
  hash = 31 * hash + self.height;
  hash = 31 * hash + self.rowSize;
  for (int i = 0; i < self.bitsSize; i++) {
    hash = 31 * hash + self.bits[i];
  }
  return hash;
}

- (NSString *) description {
  NSMutableString * result = [NSMutableString stringWithCapacity:self.height * (self.width + 1)];
  for (int y = 0; y < self.height; y++) {
    for (int x = 0; x < self.width; x++) {
      [result appendString:[self get:x y:y] ? @"X " : @"  "];
    }
    [result appendString:@"\n"];
  }
  return [NSString stringWithString:result];
}

@end

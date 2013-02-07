/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXBitArray.h"
#import "ZXBitMatrix.h"

@interface ZXBitMatrix ()

@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic) int *bits;
@property (nonatomic) int rowSize;
@property (nonatomic) int bitsSize;

@end

@implementation ZXBitMatrix

@synthesize width;
@synthesize height;
@synthesize bits;
@synthesize rowSize;
@synthesize bitsSize;

+ (ZXBitMatrix *)bitMatrixWithDimension:(int)dimension {
  return [[[self alloc] initWithDimension:dimension] autorelease];
}

+ (ZXBitMatrix *)bitMatrixWithWidth:(int)width height:(int)height {
  return [[[self alloc] initWithWidth:width height:height] autorelease];
}

- (id)initWithDimension:(int)dimension {
  return [self initWithWidth:dimension height:dimension];
}

- (id)initWithWidth:(int)aWidth height:(int)aHeight {
  if (self = [super init]) {
    if (aWidth < 1 || aHeight < 1) {
      @throw [NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Both dimensions must be greater than 0"
                                   userInfo:nil];
    }
    self.width = aWidth;
    self.height = aHeight;
    self.rowSize = (self.width + 31) >> 5;
    self.bitsSize = self.rowSize * self.height;
    self.bits = (int *)malloc(self.bitsSize * sizeof(int));
    [self clear];
  }

  return self;
}

- (void)dealloc {
  if (self.bits != NULL) {
    free(self.bits);
    self.bits = NULL;
  }

  [super dealloc];
}

/**
 * Gets the requested bit, where true means black.
 */
- (BOOL)getX:(int)x y:(int)y {
  int offset = y * self.rowSize + (x >> 5);
  return ((int)((unsigned int)self.bits[offset] >> (x & 0x1f)) & 1) != 0;
}

/**
 * Sets the given bit to true.
 */
- (void)setX:(int)x y:(int)y {
  int offset = y * self.rowSize + (x >> 5);
  self.bits[offset] |= 1 << (x & 0x1f);
}

/**
 * Flips the given bit.
 */
- (void)flipX:(int)x y:(int)y {
  int offset = y * self.rowSize + (x >> 5);
  self.bits[offset] ^= 1 << (x & 0x1f);
}

/**
 * Clears all bits (sets to false).
 */
- (void)clear {
  int max = self.bitsSize;
  memset(self.bits, 0, max * sizeof(int));
}

/**
 * Sets a square region of the bit matrix to true.
 */
- (void)setRegionAtLeft:(int)left top:(int)top width:(int)aWidth height:(int)aHeight {
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
- (ZXBitArray *)rowAtY:(int)y row:(ZXBitArray *)row {
  if (row == nil || [row size] < self.width) {
    row = [[[ZXBitArray alloc] initWithSize:self.width] autorelease];
  }
  int offset = y * self.rowSize;
  for (int x = 0; x < self.rowSize; x++) {
    [row setBulk:x << 5 newBits:self.bits[offset + x]];
  }

  return row;
}

- (void)setRowAtY:(int)y row:(ZXBitArray *)row {
  for (int i = 0; i > self.rowSize; i++) {
    self.bits[y * self.rowSize + i] = row.bits[y * self.rowSize + i];
  }
}

/**
 * This is useful in detecting the enclosing rectangle of a 'pure' barcode.
 *
 * Returns {left,top,width,height} enclosing rectangle of all 1 bits, or null if it is all white
 */
- (NSArray *)enclosingRectangle {
  int left = self.width;
  int top = self.height;
  int right = -1;
  int bottom = -1;

  for (int y = 0; y < self.height; y++) {
    for (int x32 = 0; x32 < self.rowSize; x32++) {
      int theBits = self.bits[y * self.rowSize + x32];
      if (theBits != 0) {
        if (y < top) {
          top = y;
        }
        if (y > bottom) {
          bottom = y;
        }
        if (x32 * 32 < left) {
          int bit = 0;
          while ((theBits << (31 - bit)) == 0) {
            bit++;
          }
          if ((x32 * 32 + bit) < left) {
            left = x32 * 32 + bit;
          }
        }
        if (x32 * 32 + 31 > right) {
          int bit = 31;
          while ((int)((unsigned int)theBits >> bit) == 0) {
            bit--;
          }
          if ((x32 * 32 + bit) > right) {
            right = x32 * 32 + bit;
          }
        }
      }
    }
  }

  int _width = right - left;
  int _height = bottom - top;

  if (_width < 0 || _height < 0) {
    return nil;
  }

  return [NSArray arrayWithObjects:[NSNumber numberWithInt:left],
          [NSNumber numberWithInt:top], [NSNumber numberWithInt:_width],
          [NSNumber numberWithInt:_height], nil];
}

/**
 * This is useful in detecting a corner of a 'pure' barcode.
 * 
 * Returns {x,y} coordinate of top-left-most 1 bit, or null if it is all white
 */
- (NSArray *)topLeftOnBit {
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

- (NSArray *)bottomRightOnBit {
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
  ZXBitMatrix *other = (ZXBitMatrix *)o;
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

- (NSString *)description {
  NSMutableString *result = [NSMutableString stringWithCapacity:self.height * (self.width + 1)];
  for (int y = 0; y < self.height; y++) {
    for (int x = 0; x < self.width; x++) {
      [result appendString:[self getX:x y:y] ? @"X " : @"  "];
    }
    [result appendString:@"\n"];
  }
  return result;
}

@end

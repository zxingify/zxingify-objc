#import "BinaryBitmap.h"

@implementation BinaryBitmap

@synthesize width;
@synthesize height;
@synthesize blackMatrix;
@synthesize cropSupported;
@synthesize rotateSupported;

- (id) initWithBinarizer:(Binarizer *)binarizer {
  if (self = [super init]) {
    if (binarizer == nil) {
      @throw [[[IllegalArgumentException alloc] init:@"Binarizer must be non-null."] autorelease];
    }
    binarizer = binarizer;
    matrix = nil;
  }
  return self;
}


/**
 * @return The width of the bitmap.
 */
- (int) width {
  return [[binarizer luminanceSource] width];
}


/**
 * @return The height of the bitmap.
 */
- (int) height {
  return [[binarizer luminanceSource] height];
}


/**
 * Converts one row of luminance data to 1 bit data. May actually do the conversion, or return
 * cached data. Callers should assume this method is expensive and call it as seldom as possible.
 * This method is intended for decoding 1D barcodes and may choose to apply sharpening.
 * 
 * @param y The row to fetch, 0 <= y < bitmap height.
 * @param row An optional preallocated array. If null or too small, it will be ignored.
 * If used, the Binarizer will call BitArray.clear(). Always use the returned object.
 * @return The array of bits for this row (true means black).
 */
- (BitArray *) getBlackRow:(int)y row:(BitArray *)row {
  return [binarizer getBlackRow:y param1:row];
}


/**
 * Converts a 2D array of luminance data to 1 bit. As above, assume this method is expensive
 * and do not call it repeatedly. This method is intended for decoding 2D barcodes and may or
 * may not apply sharpening. Therefore, a row from this matrix may not be identical to one
 * fetched using getBlackRow(), so don't mix and match between them.
 * 
 * @return The 2D array of bits for the image (true means black).
 */
- (BitMatrix *) blackMatrix {
  if (matrix == nil) {
    matrix = [binarizer blackMatrix];
  }
  return matrix;
}


/**
 * @return Whether this bitmap can be cropped.
 */
- (BOOL) cropSupported {
  return [[binarizer luminanceSource] cropSupported];
}


/**
 * Returns a new object with cropped image data. Implementations may keep a reference to the
 * original data rather than a copy. Only callable if isCropSupported() is true.
 * 
 * @param left The left coordinate, 0 <= left < getWidth().
 * @param top The top coordinate, 0 <= top <= getHeight().
 * @param width The width of the rectangle to crop.
 * @param height The height of the rectangle to crop.
 * @return A cropped version of this object.
 */
- (BinaryBitmap *) crop:(int)left top:(int)top width:(int)width height:(int)height {
  LuminanceSource * newSource = [[binarizer luminanceSource] crop:left param1:top param2:width param3:height];
  return [[[BinaryBitmap alloc] init:[binarizer createBinarizer:newSource]] autorelease];
}


/**
 * @return Whether this bitmap supports counter-clockwise rotation.
 */
- (BOOL) rotateSupported {
  return [[binarizer luminanceSource] rotateSupported];
}


/**
 * Returns a new object with rotated image data. Only callable if isRotateSupported() is true.
 * 
 * @return A rotated version of this object.
 */
- (BinaryBitmap *) rotateCounterClockwise {
  LuminanceSource * newSource = [[binarizer luminanceSource] rotateCounterClockwise];
  return [[[BinaryBitmap alloc] init:[binarizer createBinarizer:newSource]] autorelease];
}

- (void) dealloc {
  [binarizer release];
  [matrix release];
  [super dealloc];
}

@end

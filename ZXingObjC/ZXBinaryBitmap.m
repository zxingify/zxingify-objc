#import "ZXBinaryBitmap.h"

@interface ZXBinaryBitmap ()

@property (nonatomic, retain) ZXBinarizer* binarizer;

@end

@implementation ZXBinaryBitmap

@synthesize binarizer;
@synthesize width;
@synthesize height;
@synthesize blackMatrix=matrix;
@synthesize cropSupported;
@synthesize rotateSupported;

- (id) initWithBinarizer:(ZXBinarizer *)aBinarizer {
  if (self = [super init]) {
    if (aBinarizer == nil) {
      [NSException raise:NSInvalidArgumentException 
                  format:@"Binarizer must be non-null."];
    }
    self.binarizer = aBinarizer;
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
- (ZXBitArray *) getBlackRow:(int)y row:(ZXBitArray *)row {
  return [binarizer getBlackRow:y row:row];
}


/**
 * Converts a 2D array of luminance data to 1 bit. As above, assume this method is expensive
 * and do not call it repeatedly. This method is intended for decoding 2D barcodes and may or
 * may not apply sharpening. Therefore, a row from this matrix may not be identical to one
 * fetched using getBlackRow(), so don't mix and match between them.
 * 
 * @return The 2D array of bits for the image (true means black).
 */
- (ZXBitMatrix *) blackMatrix {
  if (matrix == nil) {
    matrix = [[binarizer blackMatrix] retain];
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
- (ZXBinaryBitmap *) crop:(int)left top:(int)top width:(int)aWidth height:(int)aHeight {
  ZXLuminanceSource * newSource = [[binarizer luminanceSource] crop:left top:top width:aWidth height:aHeight];
  return [[[ZXBinaryBitmap alloc] initWithBinarizer:[binarizer createBinarizer:newSource]] autorelease];
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
- (ZXBinaryBitmap *) rotateCounterClockwise {
  ZXLuminanceSource * newSource = [[binarizer luminanceSource] rotateCounterClockwise];
  return [[[ZXBinaryBitmap alloc] initWithBinarizer:[binarizer createBinarizer:newSource]] autorelease];
}

- (void) dealloc {
  [binarizer release];
  [matrix release];
  [super dealloc];
}

@end

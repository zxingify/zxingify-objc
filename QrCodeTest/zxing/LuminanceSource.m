#import "LuminanceSource.h"

@implementation LuminanceSource

@synthesize matrix;
@synthesize width;
@synthesize height;
@synthesize cropSupported;
@synthesize rotateSupported;

- (id) init:(int)width height:(int)height {
  if (self = [super init]) {
    width = width;
    height = height;
  }
  return self;
}


/**
 * Fetches one row of luminance data from the underlying platform's bitmap. Values range from
 * 0 (black) to 255 (white). Because Java does not have an unsigned byte type, callers will have
 * to bitwise and with 0xff for each value. It is preferable for implementations of this method
 * to only fetch this row rather than the whole image, since no 2D Readers may be installed and
 * getMatrix() may never be called.
 * 
 * @param y The row to fetch, 0 <= y < getHeight().
 * @param row An optional preallocated array. If null or too small, it will be ignored.
 * Always use the returned object, and ignore the .length of the array.
 * @return An array containing the luminance data.
 */
- (NSArray *) getRow:(int)y row:(NSArray *)row {
}


/**
 * Fetches luminance data for the underlying bitmap. Values should be fetched using:
 * int luminance = array[y * width + x] & 0xff;
 * 
 * @return A row-major 2D array of luminance values. Do not use result.length as it may be
 * larger than width * height bytes on some platforms. Do not modify the contents
 * of the result.
 */
- (NSArray *) matrix {
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
- (LuminanceSource *) crop:(int)left top:(int)top width:(int)width height:(int)height {
  @throw [[[NSException alloc] init:@"This luminance source does not support cropping."] autorelease];
}


/**
 * Returns a new object with rotated image data. Only callable if isRotateSupported() is true.
 * 
 * @return A rotated version of this object.
 */
- (LuminanceSource *) rotateCounterClockwise {
  @throw [[[NSException alloc] init:@"This luminance source does not support rotation."] autorelease];
}

@end

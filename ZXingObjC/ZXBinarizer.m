#import "ZXBinarizer.h"

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#define ZXBlack [[UIColor blackColor] CGColor]
#define ZXWhite [[UIColor whiteColor] CGColor]
#else
#define ZXBlack CGColorGetConstantColor(kCGColorBlack)
#define ZXWhite CGColorGetConstantColor(kCGColorWhite)
#endif

@implementation ZXBinarizer

@synthesize luminanceSource;
@synthesize blackMatrix;

- (id) initWithSource:(ZXLuminanceSource *)source {
  if (self = [super init]) {
    if (source == nil) {
      [NSException raise:NSInvalidArgumentException format:@"Source must be non-null."];
    }
    self.luminanceSource = source;
  }
  return self;
}


/**
 * Converts one row of luminance data to 1 bit data. May actually do the conversion, or return
 * cached data. Callers should assume this method is expensive and call it as seldom as possible.
 * This method is intended for decoding 1D barcodes and may choose to apply sharpening.
 * For callers which only examine one row of pixels at a time, the same BitArray should be reused
 * and passed in with each call for performance. However it is legal to keep more than one row
 * at a time if needed.
 * 
 * @param y The row to fetch, 0 <= y < bitmap height.
 * @param row An optional preallocated array. If null or too small, it will be ignored.
 * If used, the Binarizer will call BitArray.clear(). Always use the returned object.
 * @return The array of bits for this row (true means black).
 */
- (ZXBitArray *) getBlackRow:(int)y row:(ZXBitArray *)row {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}


/**
 * Converts a 2D array of luminance data to 1 bit data. As above, assume this method is expensive
 * and do not call it repeatedly. This method is intended for decoding 2D barcodes and may or
 * may not apply sharpening. Therefore, a row from this matrix may not be identical to one
 * fetched using getBlackRow(), so don't mix and match between them.
 * 
 * @return The 2D array of bits for the image (true means black).
 */
- (ZXBitMatrix *) blackMatrix {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}


/**
 * Creates a new object with the same type as this Binarizer implementation, but with pristine
 * state. This is needed because Binarizer implementations may be stateful, e.g. keeping a cache
 * of 1 bit data. See Effective Java for why we can't use Java's clone() method.
 * 
 * @param source The ZXLuminanceSource this Binarizer will operate on.
 * @return A new concrete Binarizer implementation object.
 */
- (ZXBinarizer *) createBinarizer:(ZXLuminanceSource *)source {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (void) dealloc {
  [luminanceSource release];
  [super dealloc];
}

- (CGImageRef)createImage {
  ZXBitMatrix *matrix = [self blackMatrix];
  ZXLuminanceSource *source = [self luminanceSource];

  int width = source.width;
  int height = source.height;

  int bytesPerRow = ((width&0xf)>>4)<<4;

  CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
  CGContextRef context = CGBitmapContextCreate (
                                                0,
                                                width,
                                                height,
                                                8,      // bits per component
                                                bytesPerRow,
                                                gray,
                                                kCGImageAlphaNone);
  CGColorSpaceRelease(gray);

  CGRect r = CGRectZero;
  r.size.width = width;
  r.size.height = height;
  CGContextSetFillColorWithColor(context, ZXBlack);
  CGContextFillRect(context, r);

  r.size.width = 1;
  r.size.height = 1;

  CGContextSetFillColorWithColor(context, ZXWhite);
  for(int y=0; y<height; y++) {
    r.origin.y = height-1-y;
    for(int x=0; x<width; x++) {
      if (![matrix get:x y:y]) {
        r.origin.x = x;
        CGContextFillRect(context, r);
      }
    }
  }
  
  CGImageRef binary = CGBitmapContextCreateImage(context); 
  
  CGContextRelease(context);
  
  return binary;
}

@end

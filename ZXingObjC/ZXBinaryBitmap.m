#import "ZXBinarizer.h"
#import "ZXBinaryBitmap.h"
#import "ZXBitArray.h"
#import "ZXBitMatrix.h"

@interface ZXBinaryBitmap ()

@property (nonatomic, retain) ZXBinarizer* binarizer;
@property (nonatomic, retain) ZXBitMatrix* matrix;

@end

@implementation ZXBinaryBitmap

@synthesize binarizer;
@synthesize matrix;

- (id)initWithBinarizer:(ZXBinarizer *)aBinarizer {
  if (self = [super init]) {
    if (aBinarizer == nil) {
      [NSException raise:NSInvalidArgumentException 
                  format:@"Binarizer must be non-null."];
    }

    self.binarizer = aBinarizer;
    self.matrix = nil;
  }

  return self;
}

- (void)dealloc {
  [binarizer release];
  [matrix release];

  [super dealloc];
}


- (int)width {
  return [[self.binarizer luminanceSource] width];
}


- (int)height {
  return [[self.binarizer luminanceSource] height];
}


/**
 * Converts one row of luminance data to 1 bit data. May actually do the conversion, or return
 * cached data. Callers should assume this method is expensive and call it as seldom as possible.
 * This method is intended for decoding 1D barcodes and may choose to apply sharpening.
 */
- (ZXBitArray *)blackRow:(int)y row:(ZXBitArray *)row error:(NSError**)error {
  return [self.binarizer blackRow:y row:row error:error];
}


/**
 * Converts a 2D array of luminance data to 1 bit. As above, assume this method is expensive
 * and do not call it repeatedly. This method is intended for decoding 2D barcodes and may or
 * may not apply sharpening. Therefore, a row from this matrix may not be identical to one
 * fetched using blackRow(), so don't mix and match between them.
 */
- (ZXBitMatrix *)blackMatrixWithError:(NSError **)error {
  if (self.matrix == nil) {
    self.matrix = [[self.binarizer blackMatrixWithError:error] retain];
  }
  return matrix;
}


- (BOOL)cropSupported {
  return [[binarizer luminanceSource] cropSupported];
}


/**
 * Returns a new object with cropped image data. Implementations may keep a reference to the
 * original data rather than a copy. Only callable if isCropSupported() is true.
 */
- (ZXBinaryBitmap *)crop:(int)left top:(int)top width:(int)aWidth height:(int)aHeight {
  ZXLuminanceSource * newSource = [[self.binarizer luminanceSource] crop:left top:top width:aWidth height:aHeight];
  return [[[ZXBinaryBitmap alloc] initWithBinarizer:[self.binarizer createBinarizer:newSource]] autorelease];
}

- (BOOL)rotateSupported {
  return [[binarizer luminanceSource] rotateSupported];
}


/**
 * Returns a new object with rotated image data. Only callable if isRotateSupported() is true.
 */
- (ZXBinaryBitmap *)rotateCounterClockwise {
  ZXLuminanceSource * newSource = [[self.binarizer luminanceSource] rotateCounterClockwise];
  return [[[ZXBinaryBitmap alloc] initWithBinarizer:[self.binarizer createBinarizer:newSource]] autorelease];
}

@end

#import "PDF417Reader.h"

NSArray * const NO_POINTS = [NSArray array];

@implementation PDF417Reader

- (void) init {
  if (self = [super init]) {
    decoder = [[[Decoder alloc] init] autorelease];
  }
  return self;
}


/**
 * Locates and decodes a PDF417 code in an image.
 * 
 * @return a String representing the content encoded by the PDF417 code
 * @throws NotFoundException if a PDF417 code cannot be found,
 * @throws FormatException if a PDF417 cannot be decoded
 */
- (Result *) decode:(BinaryBitmap *)image {
  return [self decode:image hints:nil];
}

- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  DecoderResult * decoderResult;
  NSArray * points;
  if (hints != nil && [hints containsKey:DecodeHintType.PURE_BARCODE]) {
    BitMatrix * bits = [self extractPureBits:[image blackMatrix]];
    decoderResult = [decoder decode:bits];
    points = NO_POINTS;
  }
   else {
    DetectorResult * detectorResult = [[[[Detector alloc] init:image] autorelease] detect];
    decoderResult = [decoder decode:[detectorResult bits]];
    points = [detectorResult points];
  }
  return [[[Result alloc] init:[decoderResult text] param1:[decoderResult rawBytes] param2:points param3:BarcodeFormat.PDF_417] autorelease];
}

- (void) reset {
}


/**
 * This method detects a code in a "pure" image -- that is, pure monochrome image
 * which contains only an unrotated, unskewed, image of a code, with some white border
 * around it. This is a specialized method that works exceptionally fast in this special
 * case.
 * 
 * @see com.google.zxing.qrcode.QRCodeReader#extractPureBits(BitMatrix)
 * @see com.google.zxing.datamatrix.DataMatrixReader#extractPureBits(BitMatrix)
 */
+ (BitMatrix *) extractPureBits:(BitMatrix *)image {
  NSArray * leftTopBlack = [image topLeftOnBit];
  NSArray * rightBottomBlack = [image bottomRightOnBit];
  if (leftTopBlack == nil || rightBottomBlack == nil) {
    @throw [NotFoundException notFoundInstance];
  }
  int moduleSize = [self moduleSize:leftTopBlack image:image];
  int top = leftTopBlack[1];
  int bottom = rightBottomBlack[1];
  int left = [self findPatternStart:leftTopBlack[0] y:top image:image];
  int right = [self findPatternEnd:leftTopBlack[0] y:top image:image];
  int matrixWidth = (right - left + 1) / moduleSize;
  int matrixHeight = (bottom - top + 1) / moduleSize;
  if (matrixWidth == 0 || matrixHeight == 0) {
    @throw [NotFoundException notFoundInstance];
  }
  int nudge = moduleSize >> 1;
  top += nudge;
  left += nudge;
  BitMatrix * bits = [[[BitMatrix alloc] init:matrixWidth param1:matrixHeight] autorelease];

  for (int y = 0; y < matrixHeight; y++) {
    int iOffset = top + y * moduleSize;

    for (int x = 0; x < matrixWidth; x++) {
      if ([image get:left + x * moduleSize param1:iOffset]) {
        [bits set:x param1:y];
      }
    }

  }

  return bits;
}

+ (int) moduleSize:(NSArray *)leftTopBlack image:(BitMatrix *)image {
  int x = leftTopBlack[0];
  int y = leftTopBlack[1];
  int width = [image width];

  while (x < width && [image get:x param1:y]) {
    x++;
  }

  if (x == width) {
    @throw [NotFoundException notFoundInstance];
  }
  int moduleSize = (x - leftTopBlack[0]) >>> 3;
  if (moduleSize == 0) {
    @throw [NotFoundException notFoundInstance];
  }
  return moduleSize;
}

+ (int) findPatternStart:(int)x y:(int)y image:(BitMatrix *)image {
  int width = [image width];
  int start = x;
  int transitions = 0;
  BOOL black = YES;

  while (start < width - 1 && transitions < 8) {
    start++;
    BOOL newBlack = [image get:start param1:y];
    if (black != newBlack) {
      transitions++;
    }
    black = newBlack;
  }

  if (start == width - 1) {
    @throw [NotFoundException notFoundInstance];
  }
  return start;
}

+ (int) findPatternEnd:(int)x y:(int)y image:(BitMatrix *)image {
  int width = [image width];
  int end = width - 1;

  while (end > x && ![image get:end param1:y]) {
    end--;
  }

  int transitions = 0;
  BOOL black = YES;

  while (end > x && transitions < 9) {
    end--;
    BOOL newBlack = [image get:end param1:y];
    if (black != newBlack) {
      transitions++;
    }
    black = newBlack;
  }

  if (end == x) {
    @throw [NotFoundException notFoundInstance];
  }
  return end;
}

- (void) dealloc {
  [decoder release];
  [super dealloc];
}

@end

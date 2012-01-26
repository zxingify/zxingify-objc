#import "DataMatrixReader.h"

NSArray * const NO_POINTS = [NSArray array];

@implementation DataMatrixReader

- (void) init {
  if (self = [super init]) {
    decoder = [[[Decoder alloc] init] autorelease];
  }
  return self;
}


/**
 * Locates and decodes a Data Matrix code in an image.
 * 
 * @return a String representing the content encoded by the Data Matrix code
 * @throws NotFoundException if a Data Matrix code cannot be found
 * @throws FormatException if a Data Matrix code cannot be decoded
 * @throws ChecksumException if error correction fails
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
    DetectorResult * detectorResult = [[[[Detector alloc] init:[image blackMatrix]] autorelease] detect];
    decoderResult = [decoder decode:[detectorResult bits]];
    points = [detectorResult points];
  }
  Result * result = [[[Result alloc] init:[decoderResult text] param1:[decoderResult rawBytes] param2:points param3:BarcodeFormat.DATA_MATRIX] autorelease];
  if ([decoderResult byteSegments] != nil) {
    [result putMetadata:ResultMetadataType.BYTE_SEGMENTS param1:[decoderResult byteSegments]];
  }
  if ([decoderResult eCLevel] != nil) {
    [result putMetadata:ResultMetadataType.ERROR_CORRECTION_LEVEL param1:[[decoderResult eCLevel] description]];
  }
  return result;
}

- (void) reset {
}


/**
 * This method detects a code in a "pure" image -- that is, pure monochrome image
 * which contains only an unrotated, unskewed, image of a code, with some white border
 * around it. This is a specialized method that works exceptionally fast in this special
 * case.
 * 
 * @see com.google.zxing.pdf417.PDF417Reader#extractPureBits(BitMatrix)
 * @see com.google.zxing.qrcode.QRCodeReader#extractPureBits(BitMatrix)
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
  int left = leftTopBlack[0];
  int right = rightBottomBlack[0];
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
  int width = [image width];
  int x = leftTopBlack[0];
  int y = leftTopBlack[1];

  while (x < width && [image get:x param1:y]) {
    x++;
  }

  if (x == width) {
    @throw [NotFoundException notFoundInstance];
  }
  int moduleSize = x - leftTopBlack[0];
  if (moduleSize == 0) {
    @throw [NotFoundException notFoundInstance];
  }
  return moduleSize;
}

- (void) dealloc {
  [decoder release];
  [super dealloc];
}

@end

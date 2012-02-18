#import "BinaryBitmap.h"
#import "BitMatrix.h"
#import "DataMatrixDecoder.h"
#import "DataMatrixReader.h"
#import "DataMatrixDetector.h"
#import "DecodeHintType.h"
#import "DecoderResult.h"
#import "DetectorResult.h"
#import "NotFoundException.h"
#import "Result.h"

@interface DataMatrixReader ()

- (BitMatrix *) extractPureBits:(BitMatrix *)image;
- (int) moduleSize:(NSArray *)leftTopBlack image:(BitMatrix *)image;

@end

@implementation DataMatrixReader

- (id) init {
  if (self = [super init]) {
    decoder = [[[DataMatrixDecoder alloc] init] autorelease];
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
  if (hints != nil && [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypePureBarcode]]) {
    BitMatrix * bits = [self extractPureBits:[image blackMatrix]];
    decoderResult = [decoder decodeMatrix:bits];
    points = [NSArray array];
  } else {
    DetectorResult * detectorResult = [[[[DataMatrixDetector alloc] initWithImage:[image blackMatrix]] autorelease] detect];
    decoderResult = [decoder decodeMatrix:[detectorResult bits]];
    points = [detectorResult points];
  }
  Result * result = [[[Result alloc] initWithText:[decoderResult text]
                                         rawBytes:[decoderResult rawBytes]
                                     resultPoints:points
                                           format:kBarcodeFormatDataMatrix] autorelease];
  if ([decoderResult byteSegments] != nil) {
    [result putMetadata:kResultMetadataTypeByteSegments value:[decoderResult byteSegments]];
  }
  if ([decoderResult eCLevel] != nil) {
    [result putMetadata:kResultMetadataTypeErrorCorrectionLevel value:[[decoderResult eCLevel] description]];
  }
  return result;
}

- (void) reset {
  // do nothing
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
- (BitMatrix *) extractPureBits:(BitMatrix *)image {
  NSArray * leftTopBlack = [image topLeftOnBit];
  NSArray * rightBottomBlack = [image bottomRightOnBit];
  if (leftTopBlack == nil || rightBottomBlack == nil) {
    @throw [NotFoundException notFoundInstance];
  }

  int moduleSize = [self moduleSize:leftTopBlack image:image];

  int top = [[leftTopBlack objectAtIndex:1] intValue];
  int bottom = [[rightBottomBlack objectAtIndex:1] intValue];
  int left = [[leftTopBlack objectAtIndex:0] intValue];
  int right = [[rightBottomBlack objectAtIndex:0] intValue];

  int matrixWidth = (right - left + 1) / moduleSize;
  int matrixHeight = (bottom - top + 1) / moduleSize;
  if (matrixWidth == 0 || matrixHeight == 0) {
    @throw [NotFoundException notFoundInstance];
  }

  int nudge = moduleSize >> 1;
  top += nudge;
  left += nudge;

  BitMatrix * bits = [[[BitMatrix alloc] initWithWidth:matrixWidth height:matrixHeight] autorelease];
  for (int y = 0; y < matrixHeight; y++) {
    int iOffset = top + y * moduleSize;
    for (int x = 0; x < matrixWidth; x++) {
      if ([image get:left + x * moduleSize y:iOffset]) {
        [bits set:x y:y];
      }
    }
  }

  return bits;
}

- (int) moduleSize:(NSArray *)leftTopBlack image:(BitMatrix *)image {
  int width = [image width];
  int x = [[leftTopBlack objectAtIndex:0] intValue];
  int y = [[leftTopBlack objectAtIndex:1] intValue];
  while (x < width && [image get:x y:y]) {
    x++;
  }
  if (x == width) {
    @throw [NotFoundException notFoundInstance];
  }

  int moduleSize = x - [[leftTopBlack objectAtIndex:0] intValue];
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

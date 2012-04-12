#import "ZXBarcodeFormat.h"
#import "ZXDecodeHintType.h"
#import "ZXDecoderResult.h"
#import "ZXDetectorResult.h"
#import "ZXNotFoundException.h"
#import "ZXPDF417Decoder.h"
#import "ZXPDF417Detector.h"
#import "ZXPDF417Reader.h"
#import "ZXResult.h"

@interface ZXPDF417Reader ()

- (ZXBitMatrix *) extractPureBits:(ZXBitMatrix *)image;
- (int) findPatternStart:(int)x y:(int)y image:(ZXBitMatrix *)image;
- (int) findPatternEnd:(int)x y:(int)y image:(ZXBitMatrix *)image;
- (int) moduleSize:(NSArray *)leftTopBlack image:(ZXBitMatrix *)image;

@end

@implementation ZXPDF417Reader

- (id) init {
  if (self = [super init]) {
    decoder = [[ZXPDF417Decoder alloc] init];
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
- (ZXResult *) decode:(ZXBinaryBitmap *)image {
  return [self decode:image hints:nil];
}

- (ZXResult *) decode:(ZXBinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  ZXDecoderResult * decoderResult;
  NSArray * points;
  if (hints != nil && [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypePureBarcode]]) {
    ZXBitMatrix * bits = [self extractPureBits:[image blackMatrix]];
    decoderResult = [decoder decodeMatrix:bits];
    points = [NSArray array];
  } else {
    ZXDetectorResult * detectorResult = [[[[ZXPDF417Detector alloc] initWithImage:image] autorelease] detect];
    decoderResult = [decoder decodeMatrix:[detectorResult bits]];
    points = [detectorResult points];
  }
  return [[[ZXResult alloc] initWithText:[decoderResult text]
                              rawBytes:[decoderResult rawBytes]
                                length:[decoderResult length]
                                resultPoints:points
                                format:kBarcodeFormatPDF417] autorelease];
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
 * @see com.google.zxing.qrcode.QRCodeReader#extractPureBits(BitMatrix)
 * @see com.google.zxing.datamatrix.DataMatrixReader#extractPureBits(BitMatrix)
 */
- (ZXBitMatrix *) extractPureBits:(ZXBitMatrix *)image {
  NSArray * leftTopBlack = [image topLeftOnBit];
  NSArray * rightBottomBlack = [image bottomRightOnBit];
  if (leftTopBlack == nil || rightBottomBlack == nil) {
    @throw [ZXNotFoundException notFoundInstance];
  }

  int moduleSize = [self moduleSize:leftTopBlack image:image];

  int top = [[leftTopBlack objectAtIndex:1] intValue];
  int bottom = [[rightBottomBlack objectAtIndex:1] intValue];
  int left = [self findPatternStart:[[leftTopBlack objectAtIndex:0] intValue] y:top image:image];
  int right = [self findPatternEnd:[[leftTopBlack objectAtIndex:0] intValue] y:top image:image];

  int matrixWidth = (right - left + 1) / moduleSize;
  int matrixHeight = (bottom - top + 1) / moduleSize;
  if (matrixWidth == 0 || matrixHeight == 0) {
    @throw [ZXNotFoundException notFoundInstance];
  }

  int nudge = moduleSize >> 1;
  top += nudge;
  left += nudge;

  ZXBitMatrix * bits = [[[ZXBitMatrix alloc] initWithWidth:matrixWidth height:matrixHeight] autorelease];
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

- (int) moduleSize:(NSArray *)leftTopBlack image:(ZXBitMatrix *)image {
  int x = [[leftTopBlack objectAtIndex:0] intValue];
  int y = [[leftTopBlack objectAtIndex:1] intValue];
  int width = [image width];
  while (x < width && [image get:x y:y]) {
    x++;
  }
  if (x == width) {
    @throw [ZXNotFoundException notFoundInstance];
  }

  int moduleSize = (int)((unsigned int)(x - [[leftTopBlack objectAtIndex:0] intValue]) >> 3);
  if (moduleSize == 0) {
    @throw [ZXNotFoundException notFoundInstance];
  }

  return moduleSize;
}

- (int) findPatternStart:(int)x y:(int)y image:(ZXBitMatrix *)image {
  int width = [image width];
  int start = x;

  int transitions = 0;
  BOOL black = YES;
  while (start < width - 1 && transitions < 8) {
    start++;
    BOOL newBlack = [image get:start y:y];
    if (black != newBlack) {
      transitions++;
    }
    black = newBlack;
  }
  if (start == width - 1) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  return start;
}

- (int) findPatternEnd:(int)x y:(int)y image:(ZXBitMatrix *)image {
  int width = [image width];
  int end = width - 1;

  while (end > x && ![image get:end y:y]) {
    end--;
  }
  int transitions = 0;
  BOOL black = YES;
  while (end > x && transitions < 9) {
    end--;
    BOOL newBlack = [image get:end y:y];
    if (black != newBlack) {
      transitions++;
    }
    black = newBlack;
  }

  if (end == x) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  return end;
}

- (void) dealloc {
  [decoder release];
  [super dealloc];
}

@end

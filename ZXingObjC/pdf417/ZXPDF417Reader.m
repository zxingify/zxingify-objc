#import "ZXBarcodeFormat.h"
#import "ZXBinaryBitmap.h"
#import "ZXBitMatrix.h"
#import "ZXDecodeHints.h"
#import "ZXDecoderResult.h"
#import "ZXDetectorResult.h"
#import "ZXNotFoundException.h"
#import "ZXPDF417Decoder.h"
#import "ZXPDF417Detector.h"
#import "ZXPDF417Reader.h"
#import "ZXResult.h"

@interface ZXPDF417Reader ()

@property (nonatomic, retain) ZXPDF417Decoder * decoder;

- (ZXBitMatrix *)extractPureBits:(ZXBitMatrix *)image;
- (int)findPatternStart:(int)x y:(int)y image:(ZXBitMatrix *)image;
- (int)findPatternEnd:(int)x y:(int)y image:(ZXBitMatrix *)image;
- (int)moduleSize:(NSArray *)leftTopBlack image:(ZXBitMatrix *)image;

@end

@implementation ZXPDF417Reader

@synthesize decoder;

- (id)init {
  if (self = [super init]) {
    self.decoder = [[[ZXPDF417Decoder alloc] init] autorelease];
  }
  return self;
}


- (void)dealloc {
  [decoder release];

  [super dealloc];
}

/**
 * Locates and decodes a PDF417 code in an image.
 */
- (ZXResult *)decode:(ZXBinaryBitmap *)image {
  return [self decode:image hints:nil];
}

- (ZXResult *)decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints {
  ZXDecoderResult * decoderResult;
  NSArray * points;
  if (hints != nil && hints.pureBarcode) {
    ZXBitMatrix * bits = [self extractPureBits:image.blackMatrix];
    decoderResult = [decoder decodeMatrix:bits];
    points = [NSArray array];
  } else {
    ZXDetectorResult * detectorResult = [[[[ZXPDF417Detector alloc] initWithImage:image] autorelease] detect];
    decoderResult = [decoder decodeMatrix:detectorResult.bits];
    points = detectorResult.points;
  }
  return [[[ZXResult alloc] initWithText:decoderResult.text
                                rawBytes:decoderResult.rawBytes
                                  length:decoderResult.length
                            resultPoints:points
                                  format:kBarcodeFormatPDF417] autorelease];
}

- (void)reset {
  // do nothing
}


/**
 * This method detects a code in a "pure" image -- that is, pure monochrome image
 * which contains only an unrotated, unskewed, image of a code, with some white border
 * around it. This is a specialized method that works exceptionally fast in this special
 * case.
 */
- (ZXBitMatrix *)extractPureBits:(ZXBitMatrix *)image {
  NSArray * leftTopBlack = image.topLeftOnBit;
  NSArray * rightBottomBlack = image.bottomRightOnBit;
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
      if ([image getX:left + x * moduleSize y:iOffset]) {
        [bits setX:x y:y];
      }
    }
  }

  return bits;
}

- (int)moduleSize:(NSArray *)leftTopBlack image:(ZXBitMatrix *)image {
  int x = [[leftTopBlack objectAtIndex:0] intValue];
  int y = [[leftTopBlack objectAtIndex:1] intValue];
  int width = [image width];
  while (x < width && [image getX:x y:y]) {
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

- (int)findPatternStart:(int)x y:(int)y image:(ZXBitMatrix *)image {
  int width = image.width;
  int start = x;

  int transitions = 0;
  BOOL black = YES;
  while (start < width - 1 && transitions < 8) {
    start++;
    BOOL newBlack = [image getX:start y:y];
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

- (int)findPatternEnd:(int)x y:(int)y image:(ZXBitMatrix *)image {
  int width = image.width;
  int end = width - 1;

  while (end > x && ![image getX:end y:y]) {
    end--;
  }
  int transitions = 0;
  BOOL black = YES;
  while (end > x && transitions < 9) {
    end--;
    BOOL newBlack = [image getX:end y:y];
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

@end

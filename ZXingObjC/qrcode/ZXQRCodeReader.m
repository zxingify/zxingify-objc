#import "ZXBarcodeFormat.h"
#import "ZXBinaryBitmap.h"
#import "ZXBitMatrix.h"
#import "ZXDecodeHints.h"
#import "ZXDecoderResult.h"
#import "ZXDetectorResult.h"
#import "ZXNotFoundException.h"
#import "ZXQRCodeDecoder.h"
#import "ZXQRCodeDetector.h"
#import "ZXQRCodeReader.h"
#import "ZXResult.h"

@interface ZXQRCodeReader ()

@property (nonatomic, retain) ZXQRCodeDecoder * decoder;

- (ZXBitMatrix *)extractPureBits:(ZXBitMatrix *)image;
- (int)moduleSize:(NSArray *)leftTopBlack image:(ZXBitMatrix *)image;

@end

@implementation ZXQRCodeReader

@synthesize decoder;

- (id)init {
  if (self = [super init]) {
    self.decoder = [[[ZXQRCodeDecoder alloc] init] autorelease];
  }

  return self;
}

- (void)dealloc {
  [decoder release];

  [super dealloc];
}

/**
 * Locates and decodes a QR code in an image.
 */
- (ZXResult *)decode:(ZXBinaryBitmap *)image {
  return [self decode:image hints:nil];
}

- (ZXResult *)decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints {
  ZXDecoderResult * decoderResult;
  NSArray * points;
  if (hints != nil && hints.pureBarcode) {
    ZXBitMatrix * bits = [self extractPureBits:[image blackMatrix]];
    decoderResult = [decoder decodeMatrix:bits hints:hints];
    points = [NSArray array];
  } else {
    ZXDetectorResult * detectorResult = [[[[ZXQRCodeDetector alloc] initWithImage:[image blackMatrix]] autorelease] detect:hints];
    decoderResult = [decoder decodeMatrix:[detectorResult bits] hints:hints];
    points = [detectorResult points];
  }

  ZXResult * result = [[[ZXResult alloc] initWithText:decoderResult.text
                                             rawBytes:decoderResult.rawBytes
                                               length:decoderResult.length
                                         resultPoints:points
                                               format:kBarcodeFormatQRCode] autorelease];
  if (decoderResult.byteSegments != nil) {
    [result putMetadata:kResultMetadataTypeByteSegments value:decoderResult.byteSegments];
  }
  if (decoderResult.ecLevel != nil) {
    [result putMetadata:kResultMetadataTypeErrorCorrectionLevel value:[decoderResult.ecLevel description]];
  }
  return result;
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
  int left = [[leftTopBlack objectAtIndex:0] intValue];
  int right = [[rightBottomBlack objectAtIndex:0] intValue];

  int matrixWidth = (right - left + 1) / moduleSize;
  int matrixHeight = (bottom - top + 1) / moduleSize;
  if (matrixWidth == 0 || matrixHeight == 0) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  if (matrixHeight != matrixWidth) {
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
  int height = image.height;
  int width = image.width;
  int x = [[leftTopBlack objectAtIndex:0] intValue];
  int y = [[leftTopBlack objectAtIndex:1] intValue];
  while (x < width && y < height && [image getX:x y:y]) {
    x++;
    y++;
  }
  if (x == width || y == height) {
    @throw [ZXNotFoundException notFoundInstance];
  }

  int moduleSize = x - [[leftTopBlack objectAtIndex:0] intValue];
  if (moduleSize == 0) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  return moduleSize;
}

@end

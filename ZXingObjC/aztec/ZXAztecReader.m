#import "ZXAztecDecoder.h"
#import "ZXAztecDetector.h"
#import "ZXAztecDetectorResult.h"
#import "ZXAztecReader.h"
#import "ZXBinaryBitmap.h"
#import "ZXDecodeHintType.h"
#import "ZXDecoderResult.h"
#import "ZXReader.h"
#import "ZXResult.h"
#import "ZXResultPointCallback.h"

@implementation ZXAztecReader

/**
 * Locates and decodes a Data Matrix code in an image.
 * 
 * @return a String representing the content encoded by the Data Matrix code
 * @throws NotFoundException if a Data Matrix code cannot be found
 * @throws FormatException if a Data Matrix code cannot be decoded
 * @throws ChecksumException if error correction fails
 */
- (ZXResult *) decode:(ZXBinaryBitmap *)image {
  return [self decode:image hints:nil];
}

- (ZXResult *) decode:(ZXBinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  ZXAztecDetectorResult * detectorResult = [[[[ZXAztecDetector alloc] initWithImage:[image blackMatrix]] autorelease] detect];
  NSArray *points = [detectorResult points];
  if (hints != nil && [detectorResult points] != nil) {
    id <ZXResultPointCallback> rpcb = [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeNeedResultPointCallback]];
    if (rpcb != nil) {
      for (ZXResultPoint *p in [detectorResult points]) {
        [rpcb foundPossibleResultPoint:p];
      }
    }
  }

  ZXDecoderResult *decoderResult = [[[[ZXAztecDecoder alloc] init] autorelease] decode:detectorResult];
  ZXResult * result = [[[ZXResult alloc] initWithText:[decoderResult text]
                                         rawBytes:[decoderResult rawBytes]
                                           length:[decoderResult length]
                                     resultPoints:points
                                           format:kBarcodeFormatAztec] autorelease];
  if ([decoderResult byteSegments] != nil) {
    [result putMetadata:kResultMetadataTypeByteSegments value:[decoderResult byteSegments]];
  }
  if ([decoderResult eCLevel] != nil) {
    [result putMetadata:kResultMetadataTypeErrorCorrectionLevel value:[decoderResult eCLevel]];
  }
  return result;
}

- (void)reset {
  // do nothing
}

@end

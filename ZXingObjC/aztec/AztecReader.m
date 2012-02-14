#import "AztecDecoder.h"
#import "AztecDetector.h"
#import "AztecDetectorResult.h"
#import "AztecReader.h"
#import "BinaryBitmap.h"
#import "DecodeHintType.h"
#import "DecoderResult.h"
#import "Result.h"
#import "ResultPointCallback.h"

@implementation AztecReader

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
  AztecDetectorResult * detectorResult = [[[[AztecDetector alloc] initWithImage:[image blackMatrix]] autorelease] detect];
  NSArray *points = [detectorResult points];
  if (hints != nil && [detectorResult points] != nil) {
    id <ResultPointCallback> rpcb = [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeNeedResultPointCallback]];
    if (rpcb != nil) {
      for (ResultPoint *p in [detectorResult points]) {
        [rpcb foundPossibleResultPoint:p];
      }
    }
  }

  DecoderResult *decoderResult = [[[[AztecDecoder alloc] init] autorelease] decode:detectorResult];
  Result * result = [[[Result alloc] initWithText:[decoderResult text] rawBytes:[decoderResult rawBytes]
                             resultPoints:points format:kBarcodeFormatAztec] autorelease];
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

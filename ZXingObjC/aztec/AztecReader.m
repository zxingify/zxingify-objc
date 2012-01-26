#import "AztecReader.h"

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
  AztecDetectorResult * detectorResult = [[[[Detector alloc] init:[image blackMatrix]] autorelease] detect];
  NSArray * points = [detectorResult points];
  if (hints != nil && [detectorResult points] != nil) {
    ResultPointCallback * rpcb = (ResultPointCallback *)[hints objectForKey:DecodeHintType.NEED_RESULT_POINT_CALLBACK];
    if (rpcb != nil) {

      for (int i = 0; i < [detectorResult points].length; i++) {
        [rpcb foundPossibleResultPoint:[detectorResult points][i]];
      }

    }
  }
  DecoderResult * decoderResult = [[[[Decoder alloc] init] autorelease] decode:detectorResult];
  Result * result = [[[Result alloc] init:[decoderResult text] param1:[decoderResult rawBytes] param2:points param3:BarcodeFormat.AZTEC] autorelease];
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

@end

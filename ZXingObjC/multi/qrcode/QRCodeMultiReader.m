#import "QRCodeMultiReader.h"

NSArray * const EMPTY_RESULT_ARRAY = [NSArray array];

@implementation QRCodeMultiReader

- (NSArray *) decodeMultiple:(BinaryBitmap *)image {
  return [self decodeMultiple:image hints:nil];
}

- (NSArray *) decodeMultiple:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  NSMutableArray * results = [[[NSMutableArray alloc] init] autorelease];
  NSArray * detectorResult = [[[[MultiDetector alloc] init:[image blackMatrix]] autorelease] detectMulti:hints];

  for (int i = 0; i < detectorResult.length; i++) {

    @try {
      DecoderResult * decoderResult = [[self decoder] decode:[detectorResult[i] bits]];
      NSArray * points = [detectorResult[i] points];
      Result * result = [[[Result alloc] init:[decoderResult text] param1:[decoderResult rawBytes] param2:points param3:BarcodeFormat.QR_CODE] autorelease];
      if ([decoderResult byteSegments] != nil) {
        [result putMetadata:ResultMetadataType.BYTE_SEGMENTS param1:[decoderResult byteSegments]];
      }
      if ([decoderResult eCLevel] != nil) {
        [result putMetadata:ResultMetadataType.ERROR_CORRECTION_LEVEL param1:[[decoderResult eCLevel] description]];
      }
      [results addObject:result];
    }
    @catch (ReaderException * re) {
    }
  }

  if ([results empty]) {
    return EMPTY_RESULT_ARRAY;
  }
   else {
    NSArray * resultArray = [NSArray array];

    for (int i = 0; i < [results count]; i++) {
      resultArray[i] = (Result *)[results objectAtIndex:i];
    }

    return resultArray;
  }
}

@end

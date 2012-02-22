#import "DecoderResult.h"
#import "DetectorResult.h"
#import "MultiDetector.h"
#import "QRCodeDecoder.h"
#import "QRCodeMultiReader.h"
#import "Result.h"

@implementation QRCodeMultiReader

- (NSArray *) decodeMultiple:(BinaryBitmap *)image {
  return [self decodeMultiple:image hints:nil];
}

- (NSArray *) decodeMultiple:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints {
  NSMutableArray * results = [NSMutableArray array];
  NSArray * detectorResult = [[[[MultiDetector alloc] initWithImage:[image blackMatrix]] autorelease] detectMulti:hints];
  for (int i = 0; i < [detectorResult count]; i++) {
    @try {
      DecoderResult * decoderResult = [[self decoder] decodeMatrix:[[detectorResult objectAtIndex:i] bits]];
      NSArray * points = [[detectorResult objectAtIndex:i] points];
      Result * result = [[[Result alloc] initWithText:[decoderResult text]
                                             rawBytes:[decoderResult rawBytes]
                                               length:[decoderResult length]
                                         resultPoints:points
                                               format:kBarcodeFormatQRCode] autorelease];
      if ([decoderResult byteSegments] != nil) {
        [result putMetadata:kResultMetadataTypeByteSegments value:[decoderResult byteSegments]];
      }
      if ([decoderResult eCLevel] != nil) {
        [result putMetadata:kResultMetadataTypeErrorCorrectionLevel value:[[decoderResult eCLevel] description]];
      }
      [results addObject:result];
    }
    @catch (ReaderException * re) {
    }
  }

  return results;
}

@end

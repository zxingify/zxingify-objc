#import "ZXDecoderResult.h"
#import "ZXDetectorResult.h"
#import "ZXMultiDetector.h"
#import "ZXQRCodeDecoder.h"
#import "ZXQRCodeMultiReader.h"
#import "ZXResult.h"

@implementation ZXQRCodeMultiReader

- (NSArray *) decodeMultiple:(ZXBinaryBitmap *)image {
  return [self decodeMultiple:image hints:nil];
}

- (NSArray *) decodeMultiple:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints {
  NSMutableArray * results = [NSMutableArray array];
  NSArray * detectorResult = [[[[ZXMultiDetector alloc] initWithImage:[image blackMatrix]] autorelease] detectMulti:hints];
  for (int i = 0; i < [detectorResult count]; i++) {
    @try {
      ZXDecoderResult * decoderResult = [[self decoder] decodeMatrix:[[detectorResult objectAtIndex:i] bits]];
      NSArray * points = [[detectorResult objectAtIndex:i] points];
      ZXResult * result = [[[ZXResult alloc] initWithText:[decoderResult text]
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
    @catch (ZXReaderException * re) {
    }
  }

  return results;
}

@end

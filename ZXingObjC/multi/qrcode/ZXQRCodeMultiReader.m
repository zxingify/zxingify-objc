#import "ZXDecoderResult.h"
#import "ZXDetectorResult.h"
#import "ZXMultiDetector.h"
#import "ZXQRCodeDecoder.h"
#import "ZXQRCodeMultiReader.h"
#import "ZXResult.h"

@implementation ZXQRCodeMultiReader

- (NSArray *)decodeMultiple:(ZXBinaryBitmap *)image error:(NSError **)error {
  return [self decodeMultiple:image hints:nil error:error];
}

- (NSArray *)decodeMultiple:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints error:(NSError **)error {
  ZXBitMatrix* matrix = [image blackMatrixWithError:error];
  if (!matrix) {
    return nil;
  }
  NSMutableArray * results = [NSMutableArray array];
  NSArray * detectorResult = [[[[ZXMultiDetector alloc] initWithImage:matrix] autorelease] detectMulti:hints error:error];
  if (!detectorResult) {
    return nil;
  }
  for (int i = 0; i < [detectorResult count]; i++) {
    ZXDecoderResult * decoderResult = [[self decoder] decodeMatrix:[[detectorResult objectAtIndex:i] bits] error:nil];
    if (decoderResult) {
      NSArray * points = [[detectorResult objectAtIndex:i] points];
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
      [results addObject:result];
    }
  }

  return results;
}

@end

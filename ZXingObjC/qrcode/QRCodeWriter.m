#import "QRCodeWriter.h"

int const QUIET_ZONE_SIZE = 4;

@implementation QRCodeWriter

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height {
  return [self encode:contents format:format width:width height:height hints:nil];
}

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints {
  if (contents == nil || [contents length] == 0) {
    @throw [[[IllegalArgumentException alloc] init:@"Found empty contents"] autorelease];
  }
  if (format != BarcodeFormat.QR_CODE) {
    @throw [[[IllegalArgumentException alloc] init:[@"Can only encode QR_CODE, but got " stringByAppendingString:format]] autorelease];
  }
  if (width < 0 || height < 0) {
    @throw [[[IllegalArgumentException alloc] init:[@"Requested dimensions are too small: " stringByAppendingString:width] + 'x' + height] autorelease];
  }
  ErrorCorrectionLevel * errorCorrectionLevel = ErrorCorrectionLevel.L;
  if (hints != nil) {
    ErrorCorrectionLevel * requestedECLevel = (ErrorCorrectionLevel *)[hints objectForKey:EncodeHintType.ERROR_CORRECTION];
    if (requestedECLevel != nil) {
      errorCorrectionLevel = requestedECLevel;
    }
  }
  QRCode * code = [[[QRCode alloc] init] autorelease];
  [Encoder encode:contents param1:errorCorrectionLevel param2:hints param3:code];
  return [self renderResult:code width:width height:height];
}

+ (BitMatrix *) renderResult:(QRCode *)code width:(int)width height:(int)height {
  ByteMatrix * input = [code matrix];
  int inputWidth = [input width];
  int inputHeight = [input height];
  int qrWidth = inputWidth + (QUIET_ZONE_SIZE << 1);
  int qrHeight = inputHeight + (QUIET_ZONE_SIZE << 1);
  int outputWidth = [Math max:width param1:qrWidth];
  int outputHeight = [Math max:height param1:qrHeight];
  int multiple = [Math min:outputWidth / qrWidth param1:outputHeight / qrHeight];
  int leftPadding = (outputWidth - (inputWidth * multiple)) / 2;
  int topPadding = (outputHeight - (inputHeight * multiple)) / 2;
  BitMatrix * output = [[[BitMatrix alloc] init:outputWidth param1:outputHeight] autorelease];

  for (int inputY = 0, outputY = topPadding; inputY < inputHeight; inputY++, outputY += multiple) {

    for (int inputX = 0, outputX = leftPadding; inputX < inputWidth; inputX++, outputX += multiple) {
      if ([input get:inputX param1:inputY] == 1) {
        [output setRegion:outputX param1:outputY param2:multiple param3:multiple];
      }
    }

  }

  return output;
}

@end
